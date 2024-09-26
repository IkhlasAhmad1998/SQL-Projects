-- Creating Table Encounters
CREATE TABLE encounters (
    Id UUID PRIMARY KEY,
    Start TIMESTAMP,
    Stop TIMESTAMP,
    Patient UUID REFERENCES patients(id),
    Organization UUID REFERENCES organizations(id),
    Payer UUID REFERENCES payers(id),
    EncounterClass VARCHAR(50),
    Code VARCHAR(50),
    Description TEXT,
    Base_Encounter_Cost NUMERIC,
    Total_Claim_Cost NUMERIC,
    Payer_Coverage NUMERIC,
    ReasonCode VARCHAR(50),
    ReasonDescription TEXT
);

-- Creating Table Organizations
CREATE TABLE organizations (
    Id UUID PRIMARY KEY,
    Name VARCHAR(255),
    Address VARCHAR(255),
    City VARCHAR(100),
    State VARCHAR(50),
    Zip VARCHAR(10),
    Lat NUMERIC,
    Lon NUMERIC
);

-- Creating Table Patients
CREATE TABLE patients (
    Id UUID PRIMARY KEY,
    BirthDate DATE,
    DeathDate DATE,
    Prefix VARCHAR(10),
    First VARCHAR(100),
    Last VARCHAR(100),
    Suffix VARCHAR(10),
    Maiden VARCHAR(100),
    Marital CHAR(1),
    Race VARCHAR(100),
    Ethnicity VARCHAR(100),
    Gender CHAR(1),
    BirthPlace VARCHAR(100),
    Address VARCHAR(255),
    City VARCHAR(100),
    State VARCHAR(50),
    County VARCHAR(100),
    Zip VARCHAR(10),
    Lat NUMERIC,
    Lon NUMERIC
);

-- Creating Table Payers
CREATE TABLE payers (
    Id UUID PRIMARY KEY,
    Name VARCHAR(255),
    Address VARCHAR(255),
    City VARCHAR(100),
    State_Headquartered VARCHAR(50),
    Zip VARCHAR(10),
    Phone VARCHAR(20)
);


CREATE TABLE procedures (
    Start TIMESTAMP,
    Stop TIMESTAMP,
    Patient UUID REFERENCES patients(Id),
    Encounter UUID REFERENCES encounters(Id),
    Code VARCHAR(50),
    Description TEXT,
    Base_Cost NUMERIC,
    ReasonCode VARCHAR(50),
    ReasonDescription TEXT
);