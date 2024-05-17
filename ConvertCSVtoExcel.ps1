# Define the input CSV file and the output Excel file
$csvFile = "C:\ManagedByResults.csv"
$excelFile = "C:\ManagedByResults.xlsx"

# Create an Excel application object
$excel = New-Object -ComObject Excel.Application

# Make Excel visible (optional)
$excel.Visible = $true

# Add a new workbook
$workbook = $excel.Workbooks.Add()

# Get the first worksheet
$worksheet = $workbook.Worksheets.Item(1)

# Import the CSV file
try {
    $csvContent = Import-Csv -Path $csvFile
    $rowIndex = 1

    # Write headers to the first row
    $headers = $csvContent[0].PSObject.Properties.Name
    $colIndex = 1
    foreach ($header in $headers) {
        $worksheet.Cells.Item($rowIndex, $colIndex) = $header
        $colIndex++
    }

    # Write data to the worksheet
    foreach ($row in $csvContent) {
        $rowIndex++
        $colIndex = 1
        foreach ($header in $headers) {
            $worksheet.Cells.Item($rowIndex, $colIndex) = $row.$header
            $colIndex++
        }
    }

    # Auto-fit columns for better display
    $worksheet.Columns.AutoFit()

    # Save the workbook as an Excel file
    $workbook.SaveAs($excelFile)

    Write-Host "CSV file successfully converted to Excel file: $excelFile"
} catch {
    Write-Host "Error occurred while converting CSV to Excel: $_"
} finally {
    # Close the workbook and quit Excel application
    $workbook.Close()
    $excel.Quit()

    # Release the COM objects to free memory
    [System.Runtime.InteropServices.Marshal]::ReleaseComObject($worksheet) | Out-Null
    [System.Runtime.InteropServices.Marshal]::ReleaseComObject($workbook) | Out-Null
    [System.Runtime.InteropServices.Marshal]::ReleaseComObject($excel) | Out-Null
}

# Garbage collection
[GC]::Collect()
[GC]::WaitForPendingFinalizers()