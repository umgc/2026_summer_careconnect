-- Add platform-agnostic billing fields to payments and subscriptions
ALTER TABLE payments
    ADD COLUMN platform VARCHAR(32),
    ADD COLUMN platform_purchase_token TEXT,
    ADD COLUMN platform_payer_id VARCHAR(255),
    ADD COLUMN external_transaction_id VARCHAR(255);

ALTER TABLE subscriptions
    ADD COLUMN platform VARCHAR(32),
    ADD COLUMN external_subscription_id VARCHAR(255),
    ADD COLUMN last_validated_at TIMESTAMP;

-- Note: This migration intentionally adds nullable columns for backward compatibility.
