-- Now making the id of encounters_transformed primary key
-- Step 1: Ensure the column has unique values
-- You can add a unique constraint if necessary
ALTER TABLE encounters_transformed
ADD CONSTRAINT unique_encounters_id UNIQUE (id);

-- Step 2: Add the primary key constraint
ALTER TABLE encounters_transformed
ADD CONSTRAINT pk_encounters_id PRIMARY KEY (id);

-- Managing relations with this new encounters_transformed table
ALTER TABLE encounters_transformed
ADD CONSTRAINT fk_patient
FOREIGN KEY (patient) REFERENCES patients(id)
ON DELETE CASCADE
ON UPDATE CASCADE;

ALTER TABLE encounters_transformed
ADD CONSTRAINT fk_organization
FOREIGN KEY (organization) REFERENCES organizations(id)
ON DELETE CASCADE
ON UPDATE CASCADE;

ALTER TABLE encounters_transformed
ADD CONSTRAINT fk_payer
FOREIGN KEY (payer) REFERENCES payers(id)
ON DELETE CASCADE
ON UPDATE CASCADE;

-- Managing relations between encounters_transformed and procedure table
ALTER TABLE procedures
ADD CONSTRAINT fk_enc_transformed
FOREIGN KEY (encounter) REFERENCES encounters_transformed(id)
ON DELETE CASCADE
ON UPDATE CASCADE;