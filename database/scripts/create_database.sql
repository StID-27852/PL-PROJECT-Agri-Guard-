-- Database Creation Script for AgriGuard Project
-- Student: Ineza Sonia (ID: 27852)
-- Group: Monday
-- Date: November 5, 2025

-- Create Pluggable Database
CREATE PLUGGABLE DATABASE mon_27852_sonia_AgriGuard_DB
ADMIN USER sonia IDENTIFIED BY Sonia
FILE_NAME_CONVERT = (
  'C:\APP\SONIA\PRODUCT\21C\ORADATA\XE\PDBSEED\',
  'C:\APP\SONIA\PRODUCT\21C\ORADATA\XE\MON_27852_SONIA_AGRIGUARD_DB\'
);

-- Open the PDB
ALTER PLUGGABLE DATABASE mon_27852_sonia_AgriGuard_DB OPEN;

-- Save state for auto-start
ALTER PLUGGABLE DATABASE mon_27852_sonia_AgriGuard_DB SAVE STATE;