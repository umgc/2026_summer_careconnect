# CareConnect Backend — AWS Fargate Deployment Guide (CloudFormation)

## Table of Contents

1. [Overview](#overview)
2. [Prerequisites](#prerequisites)
3. [Architecture](#architecture)
4. [Step 1: Update the Networking Stack](#step-1-update-the-networking-stack)
5. [Step 2: Build the JAR](#step-2-build-the-jar)
6. [Step 3: Build & Push the Docker Image](#step-3-build--push-the-docker-image)
7. [Step 4: Deploy the Fargate Compute Stack](#step-4-deploy-the-fargate-compute-stack)
8. [Step 5: Configure Secrets in SSM](#step-5-configure-secrets-in-ssm)
9. [Step 6: Deploy & Verify](#step-6-deploy--verify)
10. [Updating a Running Service](#updating-a-running-service)
11. [CI/CD Integration](#cicd-integration)
12. [Infrastructure Deep Dive](#infrastructure-deep-dive)
13. [Troubleshooting](#troubleshooting)
14. [Reference](#reference)

---

## Overview

The CareConnect backend is a **Spring Boot 3.4.5 / Java 17** application that connects to **PostgreSQL** (Aurora Serverless v2 in production). This guide walks through deploying it to **AWS ECS Fargate** behind an **Application Load Balancer (ALB)** using **AWS CloudFormation**.

### What's Changing

The existing compute stack (`04-compute.yaml`) uses **Lambda + API Gateway** to run the backend. This guide replaces it with **ECS Fargate + ALB**, which provides:

- Long-running processes (no 30-second timeout)
- WebSocket support natively via the Spring Boot container
- Consistent container-based runtime (same Docker image locally and in prod)
- More predictable performance (no cold starts)

| Before (Lambda) | After (Fargate) |
|---|---|
| API Gateway HTTP → Lambda | ALB → ECS Fargate |
| WebSocket API Gateway → Lambda | ALB → ECS Fargate (native WebSocket) |
| Lambda handler (`CcLambdaHandler`) | Standard Spring Boot (`CareconnectBackendApplication`) |
| S3 artifact deployment | ECR Docker image deployment |
| 30s request timeout | No request timeout |
| Amplify frontend hosting | Amplify frontend hosting (unchanged) |

### Stack Deployment Order

| Stack | Template | Status |
|-------|----------|--------|
| 01 - Networking | `01-networking.yaml` | **Updated** — adds second public subnet for ALB |
| 02 - IAM & S3 | `02-iam-s3.yaml` | Unchanged |
| 03 - Database | `03-database.yaml` | Unchanged |
| **04 - Compute** | **`04-compute.yaml`** | **Replaced** — Fargate + ALB instead of Lambda + API Gateway |
| 05 - Observability | `05-observability.yaml` | Unchanged |

---

## Prerequisites

| Tool | Version | Purpose |
|------|---------|---------|
| **Java JDK** | 17+ | Build the Spring Boot application |
| **Maven** | 3.9+ (or use included `mvnw`) | Compile and package the JAR |
| **Docker** | 20+ | Build the container image |
| **AWS CLI** | v2 | Deploy stacks and interact with AWS services |
| **An AWS account** | — | With permissions for CloudFormation, ECS, ECR, VPC, IAM, ALB, CloudWatch, SSM |

Verify your tools:

```bash
java -version          # openjdk 17.x.x
./mvnw --version       # Apache Maven 3.x.x
docker --version       # Docker 20.x+
aws --version          # aws-cli/2.x.x
```

Ensure AWS CLI is configured:

```bash
aws configure
# AWS Access Key ID: [your-key]
# AWS Secret Access Key: [your-secret]
# Default region name: us-east-1
# Default output format: json
```

Ensure the prerequisite stacks (01, 02, 03) are deployed:

```bash
aws cloudformation describe-stacks --stack-name cc-networking-dev --query 'Stacks[0].StackStatus' --region us-east-1
aws cloudformation describe-stacks --stack-name cc-iam-s3-dev --query 'Stacks[0].StackStatus' --region us-east-1
aws cloudformation describe-stacks --stack-name cc-database-dev --query 'Stacks[0].StackStatus' --region us-east-1
```

All should return `CREATE_COMPLETE` or `UPDATE_COMPLETE`.

---

## Architecture

```
┌──────────────────────────────────────────────────────────────┐
│              VPC  10.0.0.0/16  (from 01-networking)          │
│                                                              │
│  ┌─────────────────────────────────────────────────────────┐ │
│  │   Public Subnets  [from 01-networking]                  │ │
│  │   10.0.3.0/24 (AZ-a)    10.0.4.0/24 (AZ-b)            │ │
│  │                                                         │ │
│  │  ┌─────────────────────────────────────────────┐        │ │
│  │  │  Application Load Balancer (port 80/443)    │        │ │
│  │  │  [from 04-compute stack]                    │        │ │
│  │  └──────────────────┬──────────────────────────┘        │ │
│  │                     │                                   │ │
│  │           NAT Gateway [from 01-networking] ──▶ Internet │ │
│  └──────────┬──────────────────────────────────────────────┘ │
│             │                                                │
│  ┌──────────┼──────────────────────────────────────────────┐ │
│  │          │  Private Subnets  [from 01-networking]       │ │
│  │          │  10.0.1.0/24 (AZ-a)    10.0.2.0/24 (AZ-b)   │ │
│  │          ▼                                              │ │
│  │  ┌─────────────────────────────────────────────┐        │ │
│  │  │  ECS Fargate Service  [from 04-compute]     │        │ │
│  │  │  ┌───────────────────────────────────────┐  │        │ │
│  │  │  │ Task: careconnect-backend             │  │        │ │
│  │  │  │ CPU: 1024 (1 vCPU)                    │  │        │ │
│  │  │  │ Memory: 2048 MB                       │  │        │ │
│  │  │  │ Port: 8080                            │  │        │ │
│  │  │  │ Image: ECR careconnect-backend:latest │  │        │ │
│  │  │  └───────────────────────────────────────┘  │        │ │
│  │  └─────────────────────────────────────────────┘        │ │
│  │                                                         │ │
│  │  ┌─────────────────────────────────────────────┐        │ │
│  │  │  Aurora PostgreSQL  [from 03-database]      │        │ │
│  │  └─────────────────────────────────────────────┘        │ │
│  └─────────────────────────────────────────────────────────┘ │
└──────────────────────────────────────────────────────────────┘
```

---

## Step 1: Update the Networking Stack

The ALB requires **two public subnets in different Availability Zones**. The existing networking stack (`01-networking.yaml`) only has one public subnet (`PublicSubnetA`). You need to add `PublicSubnetB` and export it.

### 1a. Add the Second Public Subnet

Add the following resources and output to `cloudformation/templates/01-networking.yaml`:

**Add the subnet resource** (after the existing `PublicSubnetA` resource):

```yaml
  PublicSubnetB:
    Type: AWS::EC2::Subnet
    Properties:
      VpcId: !Ref CareConnectVPC
      CidrBlock: 10.0.4.0/24
      AvailabilityZone: !Sub "${PrimaryRegion}b"
      MapPublicIpOnLaunch: true
      Tags:
        - Key: Name
          Value: cc-public-subnet-b
```

**Add the route table association** (after the existing `PublicSubnetARouteAssociation`):

```yaml
  PublicSubnetBRouteAssociation:
    Type: AWS::EC2::SubnetRouteTableAssociation
    Properties:
      SubnetId: !Ref PublicSubnetB
      RouteTableId: !Ref PublicRouteTable
```

**Add the export** (in the `Outputs` section):

```yaml
  PublicSubnetBId:
    Value: !Ref PublicSubnetB
    Export:
      Name: !Sub "cc-networking-${Environment}-PublicSubnetB"
```

### 1b. Deploy the Updated Networking Stack

```bash
aws cloudformation deploy \
    --template-file cloudformation/templates/01-networking.yaml \
    --stack-name cc-networking-dev \
    --parameter-overrides Environment=dev \
    --capabilities CAPABILITY_NAMED_IAM \
    --no-fail-on-empty-changeset \
    --region us-east-1
```

Verify the new export exists:

```bash
aws cloudformation list-exports \
    --query 'Exports[?Name==`cc-networking-dev-PublicSubnetB`].Value' \
    --output text --region us-east-1
```

---

## Step 2: Build the JAR

From the project root:

```bash
cd backend/core

# Build the fat JAR using the docker profile (skips tests for faster builds)
./mvnw clean package -Pdocker -DskipTests
```

This produces:

```
backend/core/target/careconnect-backend-0.0.1-SNAPSHOT.jar
```

To run tests before building (recommended for production):

```bash
./mvnw clean package -Pdocker
```

### What the `docker` Profile Does

The `docker` profile in `pom.xml` enables the `spring-boot-maven-plugin` repackage goal, which creates a self-contained executable JAR with all dependencies bundled. This is the JAR that gets copied into the Docker image.

---

## Step 3: Build & Push the Docker Image

### 3a. Create the ECR Repository (First Time Only)

If you haven't deployed the compute stack yet, create the ECR repository manually:

```bash
aws ecr create-repository \
    --repository-name careconnect-backend \
    --image-scanning-configuration scanOnPush=true \
    --region us-east-1
```

Or skip this — the CloudFormation stack creates it in Step 4.

### 3b. Authenticate Docker with ECR

```bash
AWS_ACCOUNT_ID=$(aws sts get-caller-identity --query Account --output text)
AWS_REGION=us-east-1

aws ecr get-login-password --region $AWS_REGION | \
    docker login --username AWS --password-stdin \
    $AWS_ACCOUNT_ID.dkr.ecr.$AWS_REGION.amazonaws.com
```

### 3c. Build the Docker Image

From the `backend/core/` directory (where the Dockerfile lives):

```bash
docker build -t careconnect-backend .
```

**What the Dockerfile does:**
- Uses `eclipse-temurin:17-jre-jammy` (lightweight JRE, no full JDK)
- Installs `curl` for health checks
- Creates a non-root `appuser` for security
- Copies the pre-built JAR as `app.jar`
- Configures container-aware JVM flags (`-XX:+UseContainerSupport`, `-XX:MaxRAMPercentage=75.0`)
- Exposes port 8080
- Includes a health check hitting `/v1/api/test/health`

### 3d. Tag and Push

```bash
docker tag careconnect-backend:latest \
    $AWS_ACCOUNT_ID.dkr.ecr.$AWS_REGION.amazonaws.com/careconnect-backend:latest

docker push \
    $AWS_ACCOUNT_ID.dkr.ecr.$AWS_REGION.amazonaws.com/careconnect-backend:latest
```

### Build & Push — One-Liner

```bash
# From backend/core/
./mvnw clean package -Pdocker -DskipTests && \
docker build -t careconnect-backend . && \
docker tag careconnect-backend:latest $AWS_ACCOUNT_ID.dkr.ecr.$AWS_REGION.amazonaws.com/careconnect-backend:latest && \
docker push $AWS_ACCOUNT_ID.dkr.ecr.$AWS_REGION.amazonaws.com/careconnect-backend:latest
```

---

## Step 4: Deploy the Fargate Compute Stack

### 4a. The New Compute Template

Replace `cloudformation/templates/04-compute.yaml` with the following. This template removes all Lambda and API Gateway resources and replaces them with ECS Fargate + ALB, while keeping Amplify for frontend hosting.

```yaml
AWSTemplateFormatVersion: '2010-09-09'
Description: >
  CareConnect Compute Stack (Fargate)
  Provisions ECR, ECS Fargate cluster/service/task, ALB,
  and Amplify frontend hosting.
  Replaces Lambda-based 04-compute.yaml

# ============================================================
# PARAMETERS
# ============================================================
Parameters:
  Environment:
    Type: String
    Default: dev
    AllowedValues: [dev, staging, prod]

  TaskCpu:
    Type: Number
    Default: 1024
    AllowedValues: [256, 512, 1024, 2048, 4096]
    Description: >
      CPU units for the ECS task (256 = 0.25 vCPU, 1024 = 1 vCPU).

  TaskMemory:
    Type: Number
    Default: 2048
    AllowedValues: [512, 1024, 2048, 4096, 8192]
    Description: >
      Memory in MB for the ECS task.

  DesiredCount:
    Type: Number
    Default: 1
    Description: Number of Fargate tasks to run.

  ContainerImage:
    Type: String
    Default: ''
    Description: >
      Full ECR image URI. Leave empty to use the ECR repository
      created by this stack with the 'latest' tag.

  CorsAllowedList:
    Type: String
    Default: "http://localhost:*,http://127.0.0.1:*"
    Description: Comma-separated CORS origins passed to the container.

  LogRetentionDays:
    Type: Number
    Default: 90
    AllowedValues: [7, 14, 30, 60, 90, 120, 180, 365]

Conditions:
  UseDefaultImage: !Equals [!Ref ContainerImage, '']
  IsDevEnv: !Equals [!Ref Environment, dev]

# ============================================================
# RESOURCES
# ============================================================
Resources:

  # ----------------------------------------------------------
  # ECR REPOSITORY
  # ----------------------------------------------------------
  ECRRepository:
    Type: AWS::ECR::Repository
    Properties:
      RepositoryName: careconnect-backend
      ImageScanningConfiguration:
        ScanOnPush: true
      LifecyclePolicy:
        LifecyclePolicyText: |
          {
            "rules": [{
              "rulePriority": 1,
              "description": "Keep last 5 images",
              "selection": {
                "tagStatus": "any",
                "countType": "imageCountMoreThan",
                "countNumber": 5
              },
              "action": { "type": "expire" }
            }]
          }
      Tags:
        - Key: Project
          Value: careconnect
        - Key: Environment
          Value: !Ref Environment
        - Key: ManagedBy
          Value: CloudFormation

  # ----------------------------------------------------------
  # CLOUDWATCH LOG GROUP
  # ----------------------------------------------------------
  BackendLogGroup:
    Type: AWS::Logs::LogGroup
    Properties:
      LogGroupName: !Sub /ecs/careconnect-backend-${Environment}
      RetentionInDays: !Ref LogRetentionDays
      Tags:
        - Key: Project
          Value: careconnect
        - Key: Environment
          Value: !Ref Environment
        - Key: ManagedBy
          Value: CloudFormation

  # ----------------------------------------------------------
  # IAM — ECS EXECUTION ROLE (pull images, write logs)
  # ----------------------------------------------------------
  ECSExecutionRole:
    Type: AWS::IAM::Role
    Properties:
      RoleName: !Sub cc-ecs-execution-role-${Environment}
      AssumeRolePolicyDocument:
        Version: '2012-10-17'
        Statement:
          - Effect: Allow
            Principal:
              Service: ecs-tasks.amazonaws.com
            Action: sts:AssumeRole
      ManagedPolicyArns:
        - arn:aws:iam::aws:policy/service-role/AmazonECSTaskExecutionRolePolicy
      Tags:
        - Key: Project
          Value: careconnect
        - Key: Environment
          Value: !Ref Environment
        - Key: ManagedBy
          Value: CloudFormation

  # ----------------------------------------------------------
  # IAM — ECS TASK ROLE (application permissions at runtime)
  # ----------------------------------------------------------
  ECSTaskRole:
    Type: AWS::IAM::Role
    Properties:
      RoleName: !Sub cc-ecs-task-role-${Environment}
      AssumeRolePolicyDocument:
        Version: '2012-10-17'
        Statement:
          - Effect: Allow
            Principal:
              Service: ecs-tasks.amazonaws.com
            Action: sts:AssumeRole
      Tags:
        - Key: Project
          Value: careconnect
        - Key: Environment
          Value: !Ref Environment
        - Key: ManagedBy
          Value: CloudFormation

  ECSTaskPolicy:
    Type: AWS::IAM::Policy
    Properties:
      PolicyName: !Sub cc-ecs-task-policy-${Environment}
      Roles:
        - !Ref ECSTaskRole
      PolicyDocument:
        Version: '2012-10-17'
        Statement:
          # SSM Parameter Store — load secrets at startup
          - Sid: SSMAccess
            Effect: Allow
            Action:
              - ssm:GetParameter
              - ssm:GetParameters
              - ssm:GetParametersByPath
            Resource: !Sub arn:aws:ssm:${AWS::Region}:${AWS::AccountId}:parameter/careconnect/*
          # S3 — file storage
          - Sid: S3Access
            Effect: Allow
            Action:
              - s3:GetObject
              - s3:PutObject
              - s3:DeleteObject
              - s3:ListBucket
            Resource:
              - !Sub
                - arn:aws:s3:::${Bucket}
                - Bucket:
                    Fn::ImportValue: !Sub cc-iam-${Environment}-InternalS3Bucket
              - !Sub
                - arn:aws:s3:::${Bucket}/*
                - Bucket:
                    Fn::ImportValue: !Sub cc-iam-${Environment}-InternalS3Bucket
          # CloudWatch Logs
          - Sid: CloudWatchLogs
            Effect: Allow
            Action:
              - logs:CreateLogGroup
              - logs:CreateLogStream
              - logs:PutLogEvents
            Resource: '*'
          # Bedrock — AI features
          - Sid: BedrockAccess
            Effect: Allow
            Action:
              - bedrock:InvokeModel
              - bedrock:InvokeModelWithResponseStream
            Resource:
              - !Sub arn:aws:bedrock:${AWS::Region}::foundation-model/amazon.nova-pro-v1:0
              - !Sub arn:aws:bedrock:${AWS::Region}::foundation-model/amazon.nova-lite-v1:0
          # Chime — video calling
          - Sid: ChimeAccess
            Effect: Allow
            Action:
              - chime:CreateMeeting
              - chime:DeleteMeeting
              - chime:GetMeeting
              - chime:ListMeetings
              - chime:CreateAttendee
              - chime:DeleteAttendee
              - chime:GetAttendee
              - chime:ListAttendees
            Resource: '*'
          # Comprehend — sentiment analysis
          - Sid: ComprehendAccess
            Effect: Allow
            Action:
              - comprehend:DetectSentiment
              - comprehend:BatchDetectSentiment
            Resource: '*'

  # ----------------------------------------------------------
  # APPLICATION LOAD BALANCER
  # ----------------------------------------------------------
  ALB:
    Type: AWS::ElasticLoadBalancingV2::LoadBalancer
    Properties:
      Name: !Sub cc-alb-${Environment}
      Scheme: internet-facing
      Type: application
      SecurityGroups:
        - Fn::ImportValue: !Sub cc-networking-${Environment}-ApiGwSG
      Subnets:
        - Fn::ImportValue: !Sub cc-networking-${Environment}-PublicSubnetA
        - Fn::ImportValue: !Sub cc-networking-${Environment}-PublicSubnetB
      LoadBalancerAttributes:
        - Key: idle_timeout.timeout_seconds
          Value: '3600'
      Tags:
        - Key: Name
          Value: !Sub cc-alb-${Environment}
        - Key: Project
          Value: careconnect
        - Key: Environment
          Value: !Ref Environment
        - Key: ManagedBy
          Value: CloudFormation

  ALBTargetGroup:
    Type: AWS::ElasticLoadBalancingV2::TargetGroup
    Properties:
      Name: !Sub cc-backend-tg-${Environment}
      Port: 8080
      Protocol: HTTP
      VpcId:
        Fn::ImportValue: !Sub cc-networking-${Environment}-VPCId
      TargetType: ip
      TargetGroupAttributes:
        - Key: stickiness.enabled
          Value: 'true'
        - Key: stickiness.type
          Value: lb_cookie
        - Key: stickiness.lb_cookie.duration_seconds
          Value: '86400'
      HealthCheckEnabled: true
      HealthCheckPath: /v1/api/test/health
      HealthCheckPort: traffic-port
      HealthCheckProtocol: HTTP
      HealthyThresholdCount: 2
      UnhealthyThresholdCount: 3
      HealthCheckTimeoutSeconds: 10
      HealthCheckIntervalSeconds: 30
      Matcher:
        HttpCode: '200'
      Tags:
        - Key: Project
          Value: careconnect
        - Key: Environment
          Value: !Ref Environment

  ALBListenerHTTP:
    Type: AWS::ElasticLoadBalancingV2::Listener
    Properties:
      LoadBalancerArn: !Ref ALB
      Port: 80
      Protocol: HTTP
      DefaultActions:
        - Type: forward
          TargetGroupArn: !Ref ALBTargetGroup

  # ----------------------------------------------------------
  # ECS CLUSTER
  # ----------------------------------------------------------
  ECSCluster:
    Type: AWS::ECS::Cluster
    Properties:
      ClusterName: !Sub cc-fargate-cluster-${Environment}
      ClusterSettings:
        - Name: containerInsights
          Value: enabled
      Tags:
        - Key: Project
          Value: careconnect
        - Key: Environment
          Value: !Ref Environment
        - Key: ManagedBy
          Value: CloudFormation

  # ----------------------------------------------------------
  # ECS TASK DEFINITION
  # ----------------------------------------------------------
  BackendTaskDefinition:
    Type: AWS::ECS::TaskDefinition
    Properties:
      Family: !Sub cc-backend-${Environment}
      RequiresCompatibilities:
        - FARGATE
      NetworkMode: awsvpc
      Cpu: !Ref TaskCpu
      Memory: !Ref TaskMemory
      TaskRoleArn: !GetAtt ECSTaskRole.Arn
      ExecutionRoleArn: !GetAtt ECSExecutionRole.Arn
      ContainerDefinitions:
        - Name: careconnect-backend
          Image: !If
            - UseDefaultImage
            - !Sub ${AWS::AccountId}.dkr.ecr.${AWS::Region}.amazonaws.com/careconnect-backend:latest
            - !Ref ContainerImage
          Essential: true
          PortMappings:
            - ContainerPort: 8080
              Protocol: tcp
          Environment:
            - Name: SPRING_PROFILES_ACTIVE
              Value: prod
            - Name: AWS_DEFAULT_REGION
              Value: !Ref AWS::Region
            - Name: SERVER_PORT
              Value: '8080'
            - Name: CORS_ALLOWED_LIST
              Value: !Ref CorsAllowedList
            - Name: ENVIRONMENT
              Value: !Ref Environment
            - Name: AWS_S3_BUCKET
              Value:
                Fn::ImportValue: !Sub cc-iam-${Environment}-InternalS3Bucket
            - Name: LOG_LEVEL
              Value: !If [IsDevEnv, DEBUG, INFO]
          HealthCheck:
            Command:
              - CMD-SHELL
              - curl -f http://localhost:8080/v1/api/test/health || exit 1
            Interval: 30
            Timeout: 10
            Retries: 3
            StartPeriod: 90
          LogConfiguration:
            LogDriver: awslogs
            Options:
              awslogs-group: !Ref BackendLogGroup
              awslogs-region: !Ref AWS::Region
              awslogs-stream-prefix: ecs
      Tags:
        - Key: Project
          Value: careconnect
        - Key: Environment
          Value: !Ref Environment
        - Key: ManagedBy
          Value: CloudFormation

  # ----------------------------------------------------------
  # ECS SERVICE
  # ----------------------------------------------------------
  BackendService:
    Type: AWS::ECS::Service
    DependsOn: ALBListenerHTTP
    Properties:
      ServiceName: !Sub cc-backend-service-${Environment}
      Cluster: !Ref ECSCluster
      TaskDefinition: !Ref BackendTaskDefinition
      DesiredCount: !Ref DesiredCount
      LaunchType: FARGATE
      NetworkConfiguration:
        AwsvpcConfiguration:
          Subnets:
            - Fn::ImportValue: !Sub cc-networking-${Environment}-PrivateSubnetA
            - Fn::ImportValue: !Sub cc-networking-${Environment}-PrivateSubnetB
          SecurityGroups:
            - Fn::ImportValue: !Sub cc-networking-${Environment}-ComputeSG
          AssignPublicIp: DISABLED
      LoadBalancers:
        - TargetGroupArn: !Ref ALBTargetGroup
          ContainerName: careconnect-backend
          ContainerPort: 8080
      Tags:
        - Key: Project
          Value: careconnect
        - Key: Environment
          Value: !Ref Environment
        - Key: ManagedBy
          Value: CloudFormation

  # ----------------------------------------------------------
  # ECS SERVICE ERROR ALARM (replaces LambdaErrorRateAlarm)
  # ----------------------------------------------------------
  ECSServiceAlarm:
    Type: AWS::CloudWatch::Alarm
    Properties:
      AlarmName: !Sub cc-ecs-unhealthy-${Environment}
      AlarmDescription: Alert when ECS service has unhealthy tasks
      MetricName: UnhealthyHostCount
      Namespace: AWS/ApplicationELB
      Dimensions:
        - Name: TargetGroup
          Value: !GetAtt ALBTargetGroup.TargetGroupFullName
        - Name: LoadBalancer
          Value: !GetAtt ALB.LoadBalancerFullName
      Statistic: Average
      Period: 60
      EvaluationPeriods: 3
      Threshold: 1
      ComparisonOperator: GreaterThanOrEqualToThreshold
      TreatMissingData: notBreaching

  # ----------------------------------------------------------
  # AMPLIFY FRONTEND HOSTING (unchanged from Lambda version)
  # ----------------------------------------------------------
  AmplifyApp:
    Type: AWS::Amplify::App
    Properties:
      Name: !Sub careconnect-${Environment}
      Platform: WEB
      IAMServiceRole:
        Fn::ImportValue: !Sub cc-iam-${Environment}-AppRoleArn
      CustomRules:
        - Source: "</^((?!\\.).)*$/>"
          Target: /index.html
          Status: "200"
      EnvironmentVariables:
        - Name: ENV
          Value: !Ref Environment
      Tags:
        - Key: Project
          Value: careconnect
        - Key: Environment
          Value: !Ref Environment

  AmplifyBranch:
    Type: AWS::Amplify::Branch
    Properties:
      AppId: !GetAtt AmplifyApp.AppId
      BranchName: !If [IsDevEnv, dev, main]
      Stage: !If [IsDevEnv, DEVELOPMENT, PRODUCTION]

# ============================================================
# OUTPUTS
# ============================================================
Outputs:
  # Fargate-specific outputs
  ALBEndpoint:
    Description: Public URL of the Application Load Balancer
    Value: !Sub http://${ALB.DNSName}
    Export:
      Name: !Sub cc-compute-${Environment}-HttpApiEndpoint

  ALBDnsName:
    Description: ALB DNS name
    Value: !GetAtt ALB.DNSName

  ECSClusterName:
    Description: ECS cluster name
    Value: !Ref ECSCluster
    Export:
      Name: !Sub cc-compute-${Environment}-ClusterName

  ECSServiceName:
    Description: ECS service name
    Value: !GetAtt BackendService.Name
    Export:
      Name: !Sub cc-compute-${Environment}-ServiceName

  ECRRepositoryUri:
    Description: ECR repository URI for the backend image
    Value: !GetAtt ECRRepository.RepositoryUri
    Export:
      Name: !Sub cc-compute-${Environment}-ECRUri

  LogGroupName:
    Description: CloudWatch log group for backend containers
    Value: !Ref BackendLogGroup
    Export:
      Name: !Sub cc-compute-${Environment}-LogGroup

  # Amplify output (unchanged)
  AmplifyAppUrl:
    Value: !Sub https://${AmplifyBranch.BranchName}.${AmplifyApp.DefaultDomain}
    Export:
      Name: !Sub cc-compute-${Environment}-AmplifyUrl
```

### 4b. Delete the Old Lambda Compute Stack

Before deploying the new template, delete the existing Lambda-based compute stack. CloudFormation cannot update a stack when the resource types change this drastically.

> **Important:** This will delete the Lambda function, API Gateway, and WebSocket API. The Amplify app will be recreated by the new stack. If you have a custom domain on the Amplify app, note it down and reconfigure after deployment.

```bash
aws cloudformation delete-stack \
    --stack-name cc-compute-dev \
    --region us-east-1

aws cloudformation wait stack-delete-complete \
    --stack-name cc-compute-dev \
    --region us-east-1

echo "Old compute stack deleted"
```

### 4c. Validate the New Template

```bash
aws cloudformation validate-template \
    --template-body file://cloudformation/templates/04-compute.yaml \
    --region us-east-1
```

### 4d. Deploy the New Compute Stack

```bash
aws cloudformation deploy \
    --template-file cloudformation/templates/04-compute.yaml \
    --stack-name cc-compute-dev \
    --parameter-overrides \
        Environment=dev \
        TaskCpu=1024 \
        TaskMemory=2048 \
        DesiredCount=1 \
        LogRetentionDays=30 \
    --capabilities CAPABILITY_NAMED_IAM \
    --no-fail-on-empty-changeset \
    --region us-east-1
```

**For production:**

```bash
aws cloudformation deploy \
    --template-file cloudformation/templates/04-compute.yaml \
    --stack-name cc-compute-prod \
    --parameter-overrides \
        Environment=prod \
        TaskCpu=2048 \
        TaskMemory=4096 \
        DesiredCount=2 \
        LogRetentionDays=90 \
    --capabilities CAPABILITY_NAMED_IAM \
    --no-fail-on-empty-changeset \
    --region us-east-1
```

### 4e. Get the ALB URL

```bash
aws cloudformation describe-stacks \
    --stack-name cc-compute-dev \
    --query 'Stacks[0].Outputs[?OutputKey==`ALBEndpoint`].OutputValue' \
    --output text --region us-east-1
```

### Sizing Guide

| Workload | CPU (units) | Memory (MB) | Monthly Cost (est.) |
|----------|:-:|:-:|---|
| Dev/Test | 256 | 512 | ~$9 |
| Light Production | 512 | 1024 | ~$18 |
| **Standard (default)** | **1024** | **2048** | **~$36** |
| Heavy Production | 2048 | 4096 | ~$73 |

> The JVM is configured with `-XX:MaxRAMPercentage=75.0`, so it uses up to 75% of the task memory for the heap. With 2048 MB task memory, the JVM gets ~1536 MB.

---

## Step 5: Configure Secrets in SSM

The CareConnect backend reads secrets from **AWS SSM Parameter Store** when the `prod` profile is active. The ECS task role has `ssm:GetParameter*` permissions scoped to `/careconnect/*`.

### 5a. Store Secrets

```bash
# Database
aws ssm put-parameter --name "/careconnect/JDBC_URI" \
    --value "jdbc:postgresql://your-aurora-endpoint:5432/careconnect" \
    --type SecureString

aws ssm put-parameter --name "/careconnect/DB_USER" \
    --value "postgres" \
    --type SecureString

aws ssm put-parameter --name "/careconnect/DB_PASSWORD" \
    --value "your-db-password" \
    --type SecureString

# JWT Secret (must be 256+ bits, base64 encoded)
aws ssm put-parameter --name "/careconnect/SECURITY_JWT_SECRET" \
    --value "$(openssl rand -base64 32)" \
    --type SecureString

# Email (SendGrid)
aws ssm put-parameter --name "/careconnect/SENDGRID_API_KEY" \
    --value "SG.your-key" \
    --type SecureString

aws ssm put-parameter --name "/careconnect/FROM_EMAIL" \
    --value "noreply@yourdomain.com" \
    --type String

# AI/LLM
aws ssm put-parameter --name "/careconnect/DEEPSEEK_API_KEY" \
    --value "your-key" \
    --type SecureString

# Stripe
aws ssm put-parameter --name "/careconnect/STRIPE_SECRET_KEY" \
    --value "sk_live_your-key" \
    --type SecureString

# S3 bucket
aws ssm put-parameter --name "/careconnect/S3_BUCKET_NAME" \
    --value "careconnect-internal-bucket" \
    --type String

# Frontend URL (for CORS and email links)
aws ssm put-parameter --name "/careconnect/APP_FRONTEND_BASE_URL" \
    --value "https://app.careconnect.com" \
    --type String
```

### 5b. How SSM Integration Works

The application has a custom `SsmPropertySourceInitializer` that loads SSM parameters at startup when the `prod` profile is active. The ECS task definition sets `SPRING_PROFILES_ACTIVE=prod`, which triggers this behavior. Parameter names under `/careconnect/` are mapped directly to Spring environment properties.

### 5c. Environment Variables in the Task Definition

These non-secret values are set directly in the CloudFormation template:

| Variable | Value | Purpose |
|----------|-------|---------|
| `SPRING_PROFILES_ACTIVE` | `prod` | Activates production config + SSM loading |
| `AWS_DEFAULT_REGION` | `us-east-1` | Region for AWS SDK calls |
| `SERVER_PORT` | `8080` | Spring Boot listen port |
| `CORS_ALLOWED_LIST` | Parameter value | Allowed CORS origins |
| `ENVIRONMENT` | `dev`/`staging`/`prod` | Environment identifier |
| `AWS_S3_BUCKET` | Imported from stack 02 | S3 bucket for file storage |
| `LOG_LEVEL` | `DEBUG` (dev) / `INFO` (prod) | Logging verbosity |

---

## Step 6: Deploy & Verify

### 6a. Force a New Deployment (if image was pushed after stack creation)

```bash
aws ecs update-service \
    --cluster cc-fargate-cluster-dev \
    --service cc-backend-service-dev \
    --force-new-deployment \
    --region us-east-1
```

### 6b. Check ECS Service Status

```bash
aws ecs describe-services \
    --cluster cc-fargate-cluster-dev \
    --services cc-backend-service-dev \
    --query 'services[0].{status:status,running:runningCount,desired:desiredCount,deployments:deployments[*].{status:status,running:runningCount,desired:desiredCount,rolloutState:rolloutState}}' \
    --region us-east-1
```

Look for `runningCount` matching `desiredCount` and `rolloutState: COMPLETED`.

### 6c. Hit the Health Check

```bash
ALB_DNS=$(aws cloudformation describe-stacks \
    --stack-name cc-compute-dev \
    --query 'Stacks[0].Outputs[?OutputKey==`ALBDnsName`].OutputValue' \
    --output text --region us-east-1)

curl http://$ALB_DNS/v1/api/test/health
```

Expected response:

```json
{
  "status": "healthy",
  "timestamp": "2026-03-20T12:00:00",
  "message": "CareConnect API is running successfully!",
  "version": "1.0.0",
  "documentation": "Available at /swagger-ui.html"
}
```

### 6d. Check Logs

```bash
aws logs tail /ecs/careconnect-backend-dev --follow --region us-east-1
```

---

## Updating a Running Service

### Deploy a New Application Version

```bash
# 1. Build new JAR
cd backend/core
./mvnw clean package -Pdocker -DskipTests

# 2. Build, tag, and push Docker image
docker build -t careconnect-backend .
docker tag careconnect-backend:latest \
    $AWS_ACCOUNT_ID.dkr.ecr.$AWS_REGION.amazonaws.com/careconnect-backend:latest
docker push \
    $AWS_ACCOUNT_ID.dkr.ecr.$AWS_REGION.amazonaws.com/careconnect-backend:latest

# 3. Force ECS to pull the new image
aws ecs update-service \
    --cluster cc-fargate-cluster-dev \
    --service cc-backend-service-dev \
    --force-new-deployment \
    --region us-east-1

# 4. Wait for deployment to stabilize
aws ecs wait services-stable \
    --cluster cc-fargate-cluster-dev \
    --services cc-backend-service-dev \
    --region us-east-1

echo "Deployment complete!"
```

### Using Git SHA Tags (Recommended for Production)

```bash
GIT_SHA=$(git rev-parse --short HEAD)

docker tag careconnect-backend:latest \
    $AWS_ACCOUNT_ID.dkr.ecr.$AWS_REGION.amazonaws.com/careconnect-backend:$GIT_SHA

docker push \
    $AWS_ACCOUNT_ID.dkr.ecr.$AWS_REGION.amazonaws.com/careconnect-backend:$GIT_SHA

# Update the stack with the specific image
aws cloudformation deploy \
    --template-file cloudformation/templates/04-compute.yaml \
    --stack-name cc-compute-prod \
    --parameter-overrides \
        Environment=prod \
        TaskCpu=2048 \
        TaskMemory=4096 \
        DesiredCount=2 \
        ContainerImage=$AWS_ACCOUNT_ID.dkr.ecr.$AWS_REGION.amazonaws.com/careconnect-backend:$GIT_SHA \
    --capabilities CAPABILITY_NAMED_IAM \
    --region us-east-1
```

### Update Infrastructure (CPU, Memory, Task Count)

Re-run `aws cloudformation deploy` with new parameter values. CloudFormation applies only the diff:

```bash
# Scale to 3 tasks with more memory
aws cloudformation deploy \
    --template-file cloudformation/templates/04-compute.yaml \
    --stack-name cc-compute-prod \
    --parameter-overrides \
        Environment=prod \
        TaskCpu=2048 \
        TaskMemory=4096 \
        DesiredCount=3 \
    --capabilities CAPABILITY_NAMED_IAM \
    --region us-east-1
```

---

## CI/CD Integration

### Updated GitHub Actions Workflow

Update the `Deploy 04 - Compute Stack` step in `.github/workflows/cloudformation-deploy.yml` to use the new Fargate parameters instead of the Lambda-specific ones:

**Before (Lambda):**

```yaml
      - name: Deploy 04 - Compute Stack
        run: |
          aws cloudformation deploy \
            --template-file cloudformation/templates/04-compute.yaml \
            --stack-name cc-compute-${{ env.ENV }} \
            --parameter-overrides \
                Environment=${{ env.ENV }} \
                BackendArtifactS3Key=${{ secrets.BACKEND_ARTIFACT_S3_KEY }} \
            --capabilities CAPABILITY_NAMED_IAM \
            --no-fail-on-empty-changeset
          echo "Compute stack deployed"
```

**After (Fargate):**

```yaml
      - name: Deploy 04 - Compute Stack
        run: |
          aws cloudformation deploy \
            --template-file cloudformation/templates/04-compute.yaml \
            --stack-name cc-compute-${{ env.ENV }} \
            --parameter-overrides \
                Environment=${{ env.ENV }} \
                TaskCpu=${{ vars.TASK_CPU || '1024' }} \
                TaskMemory=${{ vars.TASK_MEMORY || '2048' }} \
                DesiredCount=${{ vars.DESIRED_COUNT || '1' }} \
                CorsAllowedList=${{ vars.CORS_ALLOWED_LIST || 'http://localhost:*' }} \
            --capabilities CAPABILITY_NAMED_IAM \
            --no-fail-on-empty-changeset
          echo "Compute stack deployed"
```

The `BACKEND_ARTIFACT_S3_KEY` secret is no longer needed — images are deployed to ECR separately from infrastructure.

### Full CI/CD Deploy Pipeline

For a complete pipeline that builds, pushes, and deploys:

```yaml
      # After the compute stack is deployed...
      - name: Build and Push Docker Image
        run: |
          cd backend/core
          ./mvnw clean package -Pdocker -DskipTests
          docker build -t careconnect-backend .

          AWS_ACCOUNT_ID=$(aws sts get-caller-identity --query Account --output text)
          ECR_URI=$AWS_ACCOUNT_ID.dkr.ecr.${{ env.AWS_REGION }}.amazonaws.com

          aws ecr get-login-password --region ${{ env.AWS_REGION }} | \
            docker login --username AWS --password-stdin $ECR_URI

          GIT_SHA=$(git rev-parse --short HEAD)
          docker tag careconnect-backend:latest $ECR_URI/careconnect-backend:$GIT_SHA
          docker tag careconnect-backend:latest $ECR_URI/careconnect-backend:latest
          docker push $ECR_URI/careconnect-backend:$GIT_SHA
          docker push $ECR_URI/careconnect-backend:latest

      - name: Deploy to ECS
        run: |
          aws ecs update-service \
            --cluster cc-fargate-cluster-${{ env.ENV }} \
            --service cc-backend-service-${{ env.ENV }} \
            --force-new-deployment \
            --region ${{ env.AWS_REGION }}

          aws ecs wait services-stable \
            --cluster cc-fargate-cluster-${{ env.ENV }} \
            --services cc-backend-service-${{ env.ENV }} \
            --region ${{ env.AWS_REGION }}
```

---

## Infrastructure Deep Dive

### Security Groups (from 01-networking)

**ALB Security Group (`cc-apigw-sg`):**
- Inbound: port 80 (HTTP) and port 443 (HTTPS) from `0.0.0.0/0`
- Outbound: all traffic

**ECS Security Group (`cc-ecs-sg`):**
- Inbound: port 8080 **only from the ALB security group** (no direct internet access)
- Outbound: all traffic (AWS APIs, database, external services)

**RDS Security Group (`cc-rds-sg`):**
- Inbound: port 5432 from the compute security group and VPC CIDR
- Outbound: all traffic

### IAM Roles

**Execution Role (`cc-ecs-execution-role-${Env}`):**
- Pulls images from ECR
- Writes to CloudWatch Logs
- AWS-managed `AmazonECSTaskExecutionRolePolicy`

**Task Role (`cc-ecs-task-role-${Env}`):**

| Permission | Resource | Purpose |
|---|---|---|
| `ssm:GetParameter*` | `/careconnect/*` | Load secrets at startup |
| `bedrock:InvokeModel*` | Nova Pro, Nova Lite | AI features |
| `chime:*Meeting*`, `chime:*Attendee*` | `*` | Video calling |
| `s3:Get/Put/Delete/List` | Internal S3 bucket | File storage |
| `logs:*` | `*` | CloudWatch logging |
| `comprehend:DetectSentiment` | `*` | Sentiment analysis |

### Cross-Stack Imports

```
01-networking ──▶ 04-compute
  • VPCId, PrivateSubnetA/B, PublicSubnetA/B
  • ApiGwSG (for ALB), ComputeSG (for ECS tasks)

02-iam-s3 ──▶ 04-compute
  • InternalS3Bucket (S3 bucket name)
  • AppRoleArn (for Amplify)
```

### Export Compatibility

The new stack maintains the `cc-compute-${Environment}-HttpApiEndpoint` export name so that any systems referencing the old API Gateway endpoint will now get the ALB URL instead. The following old exports are **removed** (no other stacks import them):

| Removed Export | Reason |
|---|---|
| `cc-compute-${Env}-HttpApiId` | No API Gateway |
| `cc-compute-${Env}-WsEndpoint` | WebSocket handled by Fargate natively |
| `cc-compute-${Env}-WsMgmtEndpoint` | WebSocket handled by Fargate natively |
| `cc-compute-${Env}-LambdaArn` | No Lambda |
| `cc-compute-${Env}-LambdaName` | No Lambda |

New exports added:

| New Export | Value |
|---|---|
| `cc-compute-${Env}-ClusterName` | ECS cluster name |
| `cc-compute-${Env}-ServiceName` | ECS service name |
| `cc-compute-${Env}-ECRUri` | ECR repository URI |
| `cc-compute-${Env}-LogGroup` | CloudWatch log group |

---

## Troubleshooting

### Task Won't Start

```bash
TASK_ARN=$(aws ecs list-tasks \
    --cluster cc-fargate-cluster-dev \
    --service-name cc-backend-service-dev \
    --desired-status STOPPED \
    --query 'taskArns[0]' --output text --region us-east-1)

aws ecs describe-tasks \
    --cluster cc-fargate-cluster-dev \
    --tasks $TASK_ARN \
    --query 'tasks[0].{reason:stoppedReason,container:containers[0].{reason:reason,exitCode:exitCode}}' \
    --region us-east-1
```

| Symptom | Cause | Fix |
|---|---|---|
| `CannotPullContainerError` | No image in ECR | Push image to ECR (Step 3) |
| `OutOfMemoryError` | JVM heap exceeds task memory | Increase `TaskMemory` parameter |
| Exit code 1, "missing critical env vars" | SSM parameters not created | Run Step 5a commands |
| Task starts then stops after 90s | Health check failing | Check database connectivity |
| `ResourceInitializationError` | Task can't reach ECR | Verify NAT Gateway in networking stack |

### CloudFormation Stack Failures

```bash
aws cloudformation describe-stack-events \
    --stack-name cc-compute-dev \
    --query 'StackEvents[?ResourceStatus==`CREATE_FAILED`].{Resource:LogicalResourceId,Reason:ResourceStatusReason}' \
    --region us-east-1
```

| Error | Cause | Fix |
|---|---|---|
| "No export named cc-networking-dev-PublicSubnetB" | Networking stack not updated | Complete Step 1 first |
| "cc-ecs-execution-role-dev already exists" | Role name conflict from prior attempt | Delete the orphaned role in IAM console |
| "Requires capabilities: CAPABILITY_NAMED_IAM" | Missing `--capabilities` flag | Add `--capabilities CAPABILITY_NAMED_IAM` |

### Database Connection Issues

```bash
aws logs filter-log-events \
    --log-group-name /ecs/careconnect-backend-dev \
    --filter-pattern "Connection refused" \
    --region us-east-1
```

Ensure:
- Aurora is in the same VPC (deployed via `03-database.yaml`)
- RDS security group allows port 5432 from compute security group (`cc-ecs-sg`)
- The `JDBC_URI` SSM parameter has the correct Aurora endpoint

### Connect to Running Container (ECS Exec)

```bash
# Enable ECS Exec (one-time)
aws ecs update-service \
    --cluster cc-fargate-cluster-dev \
    --service cc-backend-service-dev \
    --enable-execute-command \
    --region us-east-1

# Get the task ID
TASK_ID=$(aws ecs list-tasks --cluster cc-fargate-cluster-dev \
    --service-name cc-backend-service-dev \
    --query 'taskArns[0]' --output text --region us-east-1)

# Open a shell
aws ecs execute-command \
    --cluster cc-fargate-cluster-dev \
    --task $TASK_ID \
    --container careconnect-backend \
    --interactive \
    --command "/bin/bash" \
    --region us-east-1
```

### Delete the Stack

```bash
# Scale to zero first
aws ecs update-service \
    --cluster cc-fargate-cluster-dev \
    --service cc-backend-service-dev \
    --desired-count 0 --region us-east-1

aws ecs wait services-stable \
    --cluster cc-fargate-cluster-dev \
    --services cc-backend-service-dev --region us-east-1

# Empty ECR before deletion
aws ecr batch-delete-image \
    --repository-name careconnect-backend \
    --image-ids "$(aws ecr list-images --repository-name careconnect-backend --query 'imageIds' --output json --region us-east-1)" \
    --region us-east-1

# Delete stack
aws cloudformation delete-stack --stack-name cc-compute-dev --region us-east-1
aws cloudformation wait stack-delete-complete --stack-name cc-compute-dev --region us-east-1
```

---

## Reference

### Project File Locations

| File | Purpose |
|---|---|
| `backend/core/pom.xml` | Maven build config (Java 17, Spring Boot 3.4.5) |
| `backend/core/Dockerfile` | Container image definition |
| `backend/core/env-entry.sh` | Alternative Docker entrypoint with .env loading |
| `backend/core/src/main/resources/application.properties` | Base app config |
| `backend/core/src/main/resources/application-prod.properties` | Production overrides |
| `cloudformation/templates/01-networking.yaml` | VPC, subnets, security groups, NAT Gateway |
| `cloudformation/templates/02-iam-s3.yaml` | IAM roles, S3 buckets |
| `cloudformation/templates/03-database.yaml` | Aurora PostgreSQL Serverless v2 |
| `cloudformation/templates/04-compute.yaml` | **Fargate + ALB + Amplify (this guide)** |
| `cloudformation/templates/05-observability.yaml` | CloudWatch, SNS alerts |
| `.github/workflows/cloudformation-deploy.yml` | CI/CD pipeline |

### Required SSM Parameters (Minimum)

| Parameter | Type | Required |
|---|---|---|
| `/careconnect/JDBC_URI` | SecureString | Yes |
| `/careconnect/DB_USER` | SecureString | Yes |
| `/careconnect/DB_PASSWORD` | SecureString | Yes |
| `/careconnect/SECURITY_JWT_SECRET` | SecureString | Yes |
| `/careconnect/AWS_REGION` | String | Yes (prod) |
| `/careconnect/SENDGRID_API_KEY` | SecureString | For email |
| `/careconnect/FROM_EMAIL` | String | For email |
| `/careconnect/S3_BUCKET_NAME` | String | For file uploads |
| `/careconnect/STRIPE_SECRET_KEY` | SecureString | For payments |
| `/careconnect/APP_FRONTEND_BASE_URL` | String | For CORS/email links |

### CloudFormation Stack Parameters

| Parameter | Default | Description |
|---|---|---|
| `Environment` | `dev` | dev, staging, or prod |
| `TaskCpu` | `1024` | CPU units (256/512/1024/2048/4096) |
| `TaskMemory` | `2048` | Memory in MB (512/1024/2048/4096/8192) |
| `DesiredCount` | `1` | Number of Fargate tasks |
| `ContainerImage` | (auto) | Full ECR image URI (optional override) |
| `CorsAllowedList` | `http://localhost:*` | Comma-separated CORS origins |
| `LogRetentionDays` | `90` | CloudWatch log retention |

### Useful AWS CLI Commands

```bash
# List running tasks
aws ecs list-tasks --cluster cc-fargate-cluster-dev --service-name cc-backend-service-dev --region us-east-1

# Describe service (health, deployment status)
aws ecs describe-services --cluster cc-fargate-cluster-dev --services cc-backend-service-dev --region us-east-1

# View recent logs
aws logs tail /ecs/careconnect-backend-dev --since 30m --region us-east-1

# List ECR images
aws ecr list-images --repository-name careconnect-backend --region us-east-1

# Scale the service
aws ecs update-service --cluster cc-fargate-cluster-dev --service cc-backend-service-dev --desired-count 2 --region us-east-1

# Scale to zero (saves cost)
aws ecs update-service --cluster cc-fargate-cluster-dev --service cc-backend-service-dev --desired-count 0 --region us-east-1

# View stack outputs
aws cloudformation describe-stacks --stack-name cc-compute-dev --query 'Stacks[0].Outputs' --region us-east-1

# Update stack parameters
aws cloudformation deploy --template-file cloudformation/templates/04-compute.yaml --stack-name cc-compute-dev --parameter-overrides Environment=dev TaskCpu=2048 TaskMemory=4096 --capabilities CAPABILITY_NAMED_IAM --region us-east-1
```
