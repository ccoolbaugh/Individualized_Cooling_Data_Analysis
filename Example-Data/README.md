## DATA DICTIONARY
This folder contains example raw data files acquired during an individualized, perception-based cooling protocol. These files are imported and analyzed with the _Individualized Cooling Data Analysis_ code. 

### Data Files
The following comma-separated-value (.csv) and MATLAB (.mat) files are available to demo the code:

1. Blanketrol III Log File (20170613_S0000_PCP_B3.csv)
    * Sample Rate ~ 1 sample / 30 s
2. Thermoesthesia GUI (tGUI) Log File (20170613_S0000_PCP_tGUI_20170613_074243.csv)
    * Sample Rate ~ 1 sample / 30 s and each button press
    * For more information about the tGUI, please visit its GitHub Page <https://github.com/welcheb/Thermoesthesia_GUI>
3. Skin Temperature Log File (20170613_S0000_PCP_SkinTemp.csv)
    * Sample Rate ~ 1 sample / 30 s
    * This log file was created using AD Instrument's LabChart software. Other skin temperature log files may also be compatible.
4. PhaseTable.mat
    * Contains the cooling protocol phase start and stop times
  
Note, the filename convention of the three raw data files contains the date, subject identifier, the protocol name, and the file data type: YYYYMMDD_S####_PCP_B3/tGUI/SkinTemp. The tGUI file also requires the addition of the date and time the file was created at the end of the filename. 

### Variable Naming Conventions
The variable naming conventions and units for each data file are as follows. Variables imported into the analysis code are highlighted in **bold**.

#### Blanketrol III Log File (default format exported with the Blanketrol software)
1. Date - MM/DD/YY
2. **Time of Day** - HH:MM:ss
3. Mode - Manual or Automatic 
4. State - Cooling, Heating, or At SetPt
5. **Water Temp** - current water temperature
6. Water Units - units of the water temperature (F / C)
7. **Set Point** - water temperature set point
8. Set Point Units - units of the water set point (F / C)
9. Patient Temperature 
10. Patient Units
11. Facility / Department
12. Patient Name
13. Operator Message

#### tGUI Log File
1. **s** - time in seconds since the start of the log file
2. **level** - thermoesthesia slider position value (0-100)
3. **shiver** - shiver event indicator (0 = No; 1 = Yes)

#### Skin Temperature Log File 
1. Sel Start - s - Start of the selection window (serial time)
2. Sel End - s - End of the selection windown (serial time)
3. **Clavicle Temperature Mean** - °C - mean clavicle temperature within the selection window
4. **Forearm Temperature Mean** - °C - mean forearm temperature within the selection window
5. **Finger Temperature Mean** - °C - mean finger temperature within the selection window
6. **Sel Start** - s - Start of the selection window (time of day; HH:MM:ss)
7. **Sel End** - s - End of the selection windown (time of day; HH:MM:ss)
