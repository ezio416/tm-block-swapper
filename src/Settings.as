// c 2024-03-19
// m 2024-03-20

[Setting category="General" name="Enabled"]
bool S_Enabled = true;

[Setting category="General" name="Show/hide with game UI"]
bool S_HideWithGame = true;

[Setting category="General" name="Show/hide with Openplanet UI"]
bool S_HideWithOP = false;


[Setting category="Dev" name="Float precision" min=0 max=9]
uint S_Precision = 3;

[Setting category="Dev" name="Offset data type"]
DataType S_OffsetType = DataType::Int32;

[Setting category="Dev" name="Offset bytes skip" min=1 max=12]
uint S_OffsetSkip = 4;

[Setting category="Dev" name="Offset max distance" min=100 max=10000 description="Very high values are not recommended"]
uint S_OffsetMax = 3000;