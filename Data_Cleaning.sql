--CLEANING DATA IN SQL 

SELECT * 
FROM PortFolioProject..NashVilleHousing

-------------------------------------------------------------------------------------------------------

--STANDARDIZE DATE FORMAT
SELECT SaleDateConverted,CONVERT(DATE,SaleDate)
FROM PortFolioProject..NashVilleHousing

UPDATE PortFolioProject..NashVilleHousing
SET SaleDate = CONVERT(DATE,SaleDate)

ALTER TABLE PortFolioProject..NashVilleHousing
ADD SaleDateConverted DATE;

UPDATE PortFolioProject..NashVilleHousing
SET SaleDateConverted = CONVERT(DATE,SaleDate)

-------------------------------------------------------------------------------------------------------

--Populate Property Address Data

SELECT * 
FROM PortFolioProject..NashVilleHousing
--WHERE PropertyAddress is not NULL
ORDER BY ParcelID

SELECT a.ParcelID,a.PropertyAddress,b.ParcelID,b.PropertyAddress,ISNULL(a.PropertyAddress,b.PropertyAddress)
FROM PortFolioProject..NashVilleHousing a
JOIN PortFolioProject..NashVilleHousing b
ON a.ParcelID = b.ParcelID
AND a.[UniqueID ] <> b.[UniqueID ]
WHERE a.PropertyAddress is NULL

UPDATE a 
SET PropertyAddress = ISNULL(a.PropertyAddress,b.PropertyAddress)
FROM PortFolioProject..NashVilleHousing a 
JOIN PortFolioProject..NashVilleHousing b 
ON a.ParcelID = b.ParcelID
AND a.[UniqueID ] <> b.[UniqueID ]
WHERE a.PropertyAddress is NULL

-------------------------------------------------------------------------------------------------------

--BREAKING OUT ADDRESS INTO INDIVIDUAL COLUMNS (ADDRESS,CITY,STATE)

SELECT PropertyAddress
FROM PortFolioProject..NashVilleHousing

SELECT PropertyAddress,
SUBSTRING(PropertyAddress,1,CHARINDEX(',',PropertyAddress)-1) AS Address,
SUBSTRING(PropertyAddress,CHARINDEX(',',PropertyAddress)+1,LEN(PropertyAddress)) AS City 
FROM PortFolioProject..NashVilleHousing

ALTER TABLE PortFolioProject..NashVilleHousing
ADD SplitPropertyAddress nvarchar(255);

UPDATE PortFolioProject..NashVilleHousing
SET SplitPropertyAddress = SUBSTRING(PropertyAddress,1,CHARINDEX(',',PropertyAddress)-1);

ALTER TABLE PortFolioProject..NashVilleHousing
ADD SplitPropertyCity nvarchar(255);

UPDATE PortFolioProject..NashVilleHousing
SET SplitPropertyCity = SUBSTRING(PropertyAddress,CHARINDEX(',',PropertyAddress)+1,LEN(PropertyAddress))

SELECT PropertyAddress,SplitPropertyAddress,SplitPropertyCity
FROM PortFolioProject..NashVilleHousing


SELECT OwnerAddress
FROM PortFolioProject..NashVilleHousing

SELECT OwnerAddress,
PARSENAME(REPLACE(OwnerAddress,',','.'),3) AS Address,
PARSENAME(REPLACE(OwnerAddress,',','.'),2) AS City,
PARSENAME(REPLACE(OwnerAddress,',','.'),1) AS State
FROM PortFolioProject..NashVilleHousing
WHERE OwnerAddress is not NULL

ALTER TABLE PortFolioProject..NashVilleHousing
ADD OwnerPropertyAddress nvarchar(255);

UPDATE PortFolioProject..NashVilleHousing
SET OwnerPropertyAddress = PARSENAME(REPLACE(OwnerAddress,',','.'),3) 

ALTER TABLE PortFolioProject..NashVilleHousing
ADD OwnerPropertyCity nvarchar(255);

UPDATE PortFolioProject..NashVilleHousing
SET OwnerPropertyCity = PARSENAME(REPLACE(OwnerAddress,',','.'),2) 

ALTER TABLE PortFolioProject..NashVilleHousing
ADD OwnerPropertyState nvarchar(255);

UPDATE PortFolioProject..NashVilleHousing
SET OwnerPropertyState = PARSENAME(REPLACE(OwnerAddress,',','.'),1)

SELECT OwnerAddress,
OwnerPropertyAddress,OwnerPropertyCity,OwnerPropertyState
FROM PortFolioProject..NashVilleHousing
WHERE OwnerAddress is not null

-------------------------------------------------------------------------------------------------------

--CHANGING Y/N TO 'YES'/'NO'

SELECT DISTINCT(SoldAsVacant),COUNT(SoldAsVacant)
FROM PortFolioProject..NashVilleHousing
GROUP BY SoldAsVacant
ORDER BY 2

SELECT SoldAsVacant,CASE
WHEN SoldAsVacant='Y' THEN 'Yes'
WHEN SoldAsVacant='N' THEN 'No'
ELSE SoldAsVacant
END 
FROM PortFolioProject..NashVilleHousing

UPDATE NashVilleHousing
SET SoldAsVacant = CASE
WHEN SoldAsVacant='Y' THEN 'Yes'
WHEN SoldAsVacant='N' THEN 'No'
ELSE SoldAsVacant
END		

-------------------------------------------------------------------------------------------------------

--REMOVING DUPLICATES

WITH RowNum_CTE AS 
(
SELECT *,ROW_NUMBER() OVER (
PARTITION BY ParcelID,
			 PropertyAddress,
			 SalePrice,
			 SaleDate,
			 LegalReference
			 ORDER BY 
			 UniqueID )
			 row_num
FROM PortFolioProject..NashVilleHousing
)
SELECT *  
FROM RowNum_CTE
WHERE row_num > 1
--ORDER BY PropertyAddress

-------------------------------------------------------------------------------------------------------
 
--DELETE UNUSED COLUMNDS

SELECT * 
FROM PortFolioProject..NashVilleHousing

ALTER TABLE PortFolioProject..NashVilleHousing
DROP COLUMN OwnerAddress,PropertyAddress,TaxDistrict,SaleDate