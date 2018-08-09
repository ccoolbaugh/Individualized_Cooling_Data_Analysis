## DATA DICTIONARY
This folder contains example raw data files acquired during an individualized, perception-based cooling protocol. These files are imported and analyzed with the _Individualized Cooling Data Analysis_ code. 

### Data Files
Data for two "subjects" are provided to test the different versions of the _Individualized Cooling Data Analysis_ code:
   * S0000 - test data for Version 0.0.0
   * S0001 - test data for Version 1.0.0

The following comma-separated-value (.csv) and MATLAB (.mat) files are available to demo *Version 0.0.0* of the code:

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
    
The following comma-separated-value (.csv) and MATLAB (.mat) files are available to demo *Version 1.0.0* of the code:

1. Blanketrol III Log File (20180523_S0001_PCP_B3.csv)
    * Sample Rate ~ 1 sample / 30 s
2. Thermoesthesia GUI (tGUI) Log File (20180523_S0001_PCP_tGUI_20180523_084519.csv)
    * Sample Rate ~ 1 sample / 30 s and each button press
    * For more information about the tGUI, please visit its GitHub Page <https://github.com/welcheb/Thermoesthesia_GUI>
3. Skin Temperature iButton (DS1922L) Log Files (20180523_S0001_PCP_i##.csv)
    * i## (01 to 18) indicates the iButton sensor anatomical location
    * Sample Rate ~ 1 sample / 60 s
    * This log file was created using the [eTemperature Software and USB Reader Kit](https://www.thermochron.com/product/etemperature-kit/). Other skin temperature log files may also be compatible.
4. PhaseTable_v1.mat
    * Contains the cooling protocol phase start and stop times
5. iButtonStart.mat
    * Contains the iButton start time. Assumes all iButton sensors were configured to start at the same time of day.
    * Format: SubjectID, Date (MM/DD/YY), iButtonStartTime (HH:mm:ss)
    
Note, the filename convention of the raw data files contains the date, subject identifier, the protocol name, and the file data type: YYYYMMDD_S####_PCP_B3/tGUI/SkinTemp or i##. The tGUI file also requires the addition of the date and time the file was created at the end of the filename. 

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

#### Skin Temperature Log File (S0000 Data)
1. Sel Start - s - Start of the selection window (serial time)
2. Sel End - s - End of the selection windown (serial time)
3. **Clavicle Temperature Mean** - °C - mean clavicle temperature within the selection window
4. **Forearm Temperature Mean** - °C - mean forearm temperature within the selection window
5. **Finger Temperature Mean** - °C - mean finger temperature within the selection window
6. **Sel Start** - s - Start of the selection window (time of day; HH:MM:ss)
7. **Sel End** - s - End of the selection windown (time of day; HH:MM:ss)

#### iButton (i01 - i18) Skin Temperature Log Files (S0001 Data)
iButton files include information in the file header (rows 1-22) describing the sensor serial number, filename, type, resolution, accuracy, range, log size, sample mode, and calibration data. The _Individualized Cooling Data Analysis_ code imports only the temperature values. A separate file containing the iButton start time (see iButtonStart.mat file for formatting details) is needed to generate a time vector for the data. The code also assumes the sample rate is 1 sample/minute. 
1. Reading - arbitrary unit - sample number
2. **Values** - °C - iButton temperature 

_**iButton Skin Temperature Sensor Antomical Locations (i##)**_  
1. Forehead
2. Back of Neck
3. Right Back Upper Quadrant
4. Left Front Upper Quadrant
5. Right Lateral Upper Arm
6. Left Lateral Mid Arm
7. Left Outer Hand
8. Right Front Lower Quadrant
9. Left Back Lower Quadrant
10. Right Upper Quadricep
11. Left Mid Hamstring
12. Right Mid Shin
13. Left Mid Calf
14. Right Top of Foot
15. Right Supra Clavicular Region
16. Center of Sternum
17. Left Inner Forearm
18. Left Middle Finger

_**iButton Skin Temperature Calculations**_
1. **Mean Body Surface Temperature** - iButton sensors 01-14 were positioned according to ISO STANDARD 9886-2004. Mean body surface temperature represents a weighted average of these values calculated according to the following equation:   
   * Mean Body Surface Temperature = (Forehead*0.07) + (Neck*0.07) + (Right Scapula*0.07) + (Left Chest*0.07) + (Right Deltoid*0.07) + (Left Elbow*0.07) + (Right Abdomen*0.07) + (Left Hand*0.07) + (Left Lumbar *0.07) + (Right Thigh*0.07) + (Left Hamstring*0.07) + (Right Shinbone*0.07) + (Left Gastrocnemius*0.07) + (Right Instep*0.07)  
   * **REF:** ISO-standard 9886:2004 Ergonomics – Evaluation of thermal strain by physiological measurements, International Standards Organization, Geneva, S. in (2004).

2. **Body Temperature Gradient** - iButton sensors 8, 14, 10, 15, and 7 were used to calculate the difference between the distal and proximal regions of the body according to the equation proposed by Boon et al.:   
   * Body Temperature Gradient = (Left Hand + Right Instep)/2 - (Right Thigh*0.383) + (Right Clavicular*0.293) + (Right Abdomen*0.324)  
   * **REF:** Boon, M. R. et al. Supraclavicular Skin Temperature as a Measure of 18F-FDG Uptake by BAT in Human Subjects. PLoS One 9, e98822 (2014).

3. **Peripheral Vasoconstriction** - iButton sensors 17 and 18 were used to calculate peripheral vasoconstriction according to the equation proposed by Rubinstein and Sessler:  
   * Peripheral Vasoconstrction = (Left Forearm - Left Middle Finger)
   * **REF:** Rubinstein, E. H., and Sessler, D. I. (1990). Skin-surface temperature gradients correlate with fingertip blood flow in humans. Anesthesiology 73, 541–545. doi: 10.1017/CBO9781107415324.004

4. **Supraclavicular Temperature Gradient** - iButton sensors 15 and 16 were used to calculate the supraclavicular temperature gradient according to the equation proposed by Lee et al.:  
   * Supraclavicular Temperature Gradient = (Right Supraclavicular - Right Chest)
   * **REF:** Lee, P. et al. Hot fat in a cool man: Infrared thermography and brown adipose tissue. Diabetes, Obes. Metab. 13, 92–93 (2011).
