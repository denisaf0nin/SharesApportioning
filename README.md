# Shares Apportioning Calculator
This is a Shiny App calculator allowing to change brand shares while keeping total sum at 100% and splitting the remainder across other brands proportional to their existing share.
![SharesApportioningTool](https://user-images.githubusercontent.com/59995500/126486168-da7490c9-0261-43e3-a1a1-8cbe2e0a77f6.jpg)


**This folder contains:**
* UI and Server scripts for the Shiny App
* [Input example Excel file](https://github.com/denisaf0nin/SharesApportioning/blob/main/Input%20example.xlsx?raw=true) (mock data)
* [Link to the App at shinyapps.io](https://denisafonin.shinyapps.io/SharesApportioning/)

**INSTRUCTIONS:**
1. Open the App
2. Download the Input example file. Copy data from the Excel file (the outlined cell range)
3. Paste to A1 cell of the app
4. Press Crop (The app is designed to work with variable number of columns. By pressing Crop you set the table range to non-empty cells)
5. Edit numbers in the table
6. Press Apportion to get the table to sum up to 100% by distributing the difference across the ticked lines proportionally
7. Select and copy data for further use

*Note: The app is designed to take input that starts with four text columns and 1 to 16 subsequent numerical columns containing percentage share information and formatted as floats*
