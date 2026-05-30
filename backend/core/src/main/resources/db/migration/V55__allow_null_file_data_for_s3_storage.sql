-- Allow file_data to be NULL when files are stored in S3 (not in the database).
-- In S3 storage mode, the file bytes live in S3 and file_data is intentionally empty.
ALTER TABLE user_files ALTER COLUMN file_data DROP NOT NULL;
