-- Cleaning Data in SQL Queries

SELECT *
From dbo.NashvilleHousing
----------------------------------------------------------------------

--Standardize Data Format

SELECT *
From dbo.NashvilleHousing

ALTER TABLE NashvilleHousing
Add SaleDateConverted Date;

Update NashvilleHousing
SET SaleDateConverted = CONVERT(Date,SaleDate)
-----------------------------------------------------------------------------------

--Populate Property Address Data 

SELECT *
From dbo.NashvilleHousing
-- PropertyAddress IS NULL
ORDER BY ParcelID


SELECT A.ParcelID,A.PropertyAddress,B.ParcelID,B.PropertyAddress
,ISNULL(A.PropertyAddress,B.PropertyAddress) as PropertyAddress2
From dbo.NashvilleHousing A
JOIN dbo.NashvilleHousing B
	 on A.ParcelID = B.ParcelID
	 AND A.[UniqueID] <> B.[UniqueID]
Where A.PropertyAddress IS NULL

Update A
SET PropertyAddress = ISNULL(A.PropertyAddress,B.PropertyAddress) 
From dbo.NashvilleHousing A
JOIN dbo.NashvilleHousing B
	 on A.ParcelID = B.ParcelID
	 AND A.[UniqueID] <> B.[UniqueID]
-----------------------------------------------------------------------------------------

--Breaking out Adress int Individual Columns(Adress,City,State) using SUBSTRINGS 

SELECT PropertyAddress
From dbo.NashvilleHousing
-- PropertyAddress IS NULL
--ORDER BY ParcelID

SELECT 
SUBSTRING(PropertyAddress, 1, CHARINDEX(',',PropertyAddress)-1) as Address
,SUBSTRING(PropertyAddress, CHARINDEX(',',PropertyAddress)+1, LEN(PropertyAddress)) as City

From dbo.NashvilleHousing


ALTER TABLE NashvilleHousing
Add PropertySplitAddress NVARCHAR(255);

Update NashvilleHousing
SET PropertySplitAddress = SUBSTRING(PropertyAddress, 1, CHARINDEX(',',PropertyAddress)-1)


ALTER TABLE NashvilleHousing
Add PropertySplitCity NVARCHAR(255);

SELECT *
From dbo.NashvilleHousing 

--Breaking out Adress int Individual Columns(Adress,City,State) using PARSENAME

SELECT OwnerAddress
From dbo.NashvilleHousing

SELECT 
PARSENAME(REPLACE(OwnerAddress,',', '.'),3)
,PARSENAME(REPLACE(OwnerAddress,',', '.'),2)
,PARSENAME(REPLACE(OwnerAddress,',', '.'),1)
From dbo.NashvilleHousing

ALTER TABLE NashvilleHousing
Add OwnerSplitAddress NVARCHAR(255);

Update NashvilleHousing
SET OwnerSplitAddress = PARSENAME(REPLACE(OwnerAddress,',', '.'),3)

ALTER TABLE NashvilleHousing
Add QwnerSplitCity NVARCHAR(255);

Update NashvilleHousing
SET QwnerSplitCity = PARSENAME(REPLACE(OwnerAddress,',', '.'),2)

ALTER TABLE NashvilleHousing
Add OwnerSplitState NVARCHAR(255);

Update NashvilleHousing
SET  OwnerSplitState = PARSENAME(REPLACE(OwnerAddress,',', '.'),1)

SELECT *
From dbo.NashvilleHousing 
--------------------------------------------------------------------------------------------------

-- Change Y and N to Yes and No in 'Sold as Vacant' field

SELECT Distinct(SoldAsVacant),Count(SoldAsVacant)
From dbo.NashvilleHousing
GROUP BY SoldAsVacant
ORDER BY 2

SELECT SoldAsVacant
,CASE When SoldAsVacant = 'Y' THEN 'Yes'
	  When SoldAsVacant = 'N' THEN 'No'
	  ELSE SoldAsVacant
	  END
From dbo.NashvilleHousing

UPDATE NashvilleHousing
SET SoldAsVacant = CASE When SoldAsVacant = 'Y' THEN 'Yes'
	  When SoldAsVacant = 'N' THEN 'No'
	  ELSE SoldAsVacant
	  END
---------------------------------------------------------------------------------------------------

-- REMOVE DUPLICATES (Creating CTE)

WITH RowNumCTE AS(
SELECT *,
	ROW_NUMBER()OVER(
	PARTITION BY ParcelID,
				 PropertyAddress,
				 SalePrice,
				 SaleDate,
				 LegalReference
				 ORDER BY 
					UniqueID
					)row_num
From dbo.NashvilleHousing
--ORDER BY ParcelID 
)
SELECT *
From RowNumCTE
Where row_num > 1
Order by PropertyAddress



WITH RowNumCTE AS(
SELECT *,
	ROW_NUMBER()OVER(
	PARTITION BY ParcelID,
				 PropertyAddress,
				 SalePrice,
				 SaleDate,
				 LegalReference
				 ORDER BY 
					UniqueID
					)row_num
From dbo.NashvilleHousing
--ORDER BY ParcelID 
)
DELETE
From RowNumCTE
Where row_num > 1
-----------------------------------------------------------------------------------------

--DELETE UNUSED COLUMNS 

SELECT *
From dbo.NashvilleHousing

ALTER TABLE dbo.NashvilleHousing
DROP COLUMN OwnerAddress, TaxDistrict,PropertyAddress


ALTER TABLE dbo.NashvilleHousing
DROP COLUMN SaleDate
