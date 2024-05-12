/*

Cleaning Data in SQL Queries

*/

--Standadize Date Format

SELECT SaleDateConverted, CONVERT(Date, SaleDate)
FROM PortfolioProject1.dbo.NashvilleHousing 

ALTER TABLE NashvilleHousing
ADD SaleDateConverted Date;

UPDATE NashvilleHousing
SET SaleDateConverted = CONVERT(Date, SaleDate)

--Populate Property Address Data

SELECT *
FROM PortfolioProject1.dbo.NashvilleHousing 
--WHERE PropertyAddress is null
ORDER BY ParcelID


SELECT a.ParcelID, a.PropertyAddress, b.ParcelID, b.PropertyAddress, ISNULL(a.PropertyAddress, b.PropertyAddress)
FROM PortfolioProject1.dbo.NashvilleHousing AS a
JOIN PortfolioProject1.dbo.NashvilleHousing AS b
		ON a.parcelid = b.parcelid
		AND a.uniqueID <> b.uniqueID
WHERE a.PropertyAddress is null


UPDATE a
SET PropertyAddress = ISNULL(a.PropertyAddress, b.PropertyAddress)
FROM PortfolioProject1.dbo.NashvilleHousing AS a
JOIN PortfolioProject1.dbo.NashvilleHousing AS b
		ON a.parcelid = b.parcelid
		AND a.uniqueID <> b.uniqueID
WHERE a.PropertyAddress is null


--Breaking out Address into Individual Columns (Address, City, State) using SUBSTRING and Charindex

SELECT *
FROM PortfolioProject1.dbo.NashvilleHousing 
--WHERE PropertyAddress is null
ORDER BY ParcelID

SELECT
SUBSTRING(PropertyAddress, 1, CHARINDEX(',', PropertyAddress)-1) AS Address, /*CHARINDEX(',', PropertyAddress)*/ 
SUBSTRING(PropertyAddress, CHARINDEX(',', PropertyAddress)+1, LEN(PropertyAddress)) AS City
FROM PortfolioProject1.dbo.NashvilleHousing

ALTER TABLE PortfolioProject1.dbo.NashvilleHousing
ADD PropertySplitAddress Nvarchar(255);

UPDATE PortfolioProject1.dbo.NashvilleHousing
SET PropertySplitAddress = SUBSTRING(PropertyAddress, 1, CHARINDEX(',', PropertyAddress)-1)

ALTER TABLE PortfolioProject1.dbo.NashvilleHousing
ADD PropertySplitCity Nvarchar(255);

UPDATE PortfolioProject1.dbo.NashvilleHousing
SET PropertySplitCity = SUBSTRING(PropertyAddress, CHARINDEX(',', PropertyAddress)+1, LEN(PropertyAddress))

SELECT *
FROM PortfolioProject1.dbo.NashvilleHousing


--Breaking out OwnerAddress into Individual Columns (Address, City, State) using a different method: PARSENAME and REPLACE


SELECT OwnerAddress
FROM PortfolioProject1.dbo.NashvilleHousing

SELECT
PARSENAME(REPLACE(OwnerAddress,',','.'),3),
PARSENAME(REPLACE(OwnerAddress,',','.'),2),
PARSENAME(REPLACE(OwnerAddress,',','.'),1)
FROM PortfolioProject1.dbo.NashvilleHousing


ALTER TABLE PortfolioProject1.dbo.NashvilleHousing
ADD OwnerSplitAddress Nvarchar(255);

UPDATE PortfolioProject1.dbo.NashvilleHousing
SET OwnerSplitAddress = PARSENAME(REPLACE(OwnerAddress,',','.'),3)

ALTER TABLE PortfolioProject1.dbo.NashvilleHousing
ADD OwnerSplitCity Nvarchar(255);

UPDATE PortfolioProject1.dbo.NashvilleHousing
SET OwnerSplitCity = PARSENAME(REPLACE(OwnerAddress,',','.'),2)

ALTER TABLE PortfolioProject1.dbo.NashvilleHousing
ADD OwnerSplitState Nvarchar(255);

UPDATE PortfolioProject1.dbo.NashvilleHousing
SET OwnerSplitState = PARSENAME(REPLACE(OwnerAddress,',','.'),1)



--Change Y and N to YES and NO in "Sold as Vacant" field

SELECT DISTINCT(SoldAsVacant), COUNT(SoldAsVacant) AS CountSoldAsVacant
FROM PortfolioProject1.dbo.NashvilleHousing
GROUP BY SoldAsVacant
ORDER BY 2

SELECT SoldAsVacant,
 CASE WHEN SoldAsVacant = 'Y' THEN 'Yes'
	 WHEN SoldAsVacant = 'N' THEN 'No'
	 ELSE SoldAsVacant
	 END
FROM PortfolioProject1.dbo.NashvilleHousing

UPDATE PortfolioProject1.dbo.NashvilleHousing
SET SoldAsVacant = CASE WHEN SoldAsVacant = 'Y' THEN 'Yes'
	 WHEN SoldAsVacant = 'N' THEN 'No'
	 ELSE SoldAsVacant
	 END


/* 
Remove Duplicates (as a good practice we'll normally create a temp table/cte
and then delete duplicates instead of deleting data straight from the database)
using ROW NUMBER
*/

WITH RowNumCTE AS(
SELECT *,
	ROW_NUMBER() OVER (
	PARTITION BY ParcelID,
				 PropertyAddress,
				 SaleDate,
				 LegalReference
				 ORDER BY
					UniqueID
					)row_num
FROM PortfolioProject1.dbo.NashvilleHousing
--ORDER BY ParcelID
)
DELETE
--SELECT * (to check if the duplicates have been deleted)
FROM RowNumCTE
WHERE row_num > 1
--ORDER BY PropertyAddress


--Delete Unused Columns (asa good practice ask for permission to do that on raw data)

SELECT *
FROM PortfolioProject1.dbo.NashvilleHousing

ALTER TABLE PortfolioProject1.dbo.NashvilleHousing
DROP COLUMN OwnerAddress, TaxDistrict, PropertyAddress

ALTER TABLE PortfolioProject1.dbo.NashvilleHousing
DROP COLUMN SaleDate