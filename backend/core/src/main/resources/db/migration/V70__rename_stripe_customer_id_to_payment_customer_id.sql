ALTER TABLE users RENAME COLUMN stripe_customer_id TO payment_customer_id;
ALTER TABLE subscriptions RENAME COLUMN stripe_customer_id TO payment_customer_id;
