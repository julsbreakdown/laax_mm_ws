# Ready-made survey project

`laax-survey/` is the project modules 04 to 07 build and use, for anyone short on time or without the patience for the form designer.

- `laax-survey.qgz`: OpenStreetMap background, layer `observations`, saved with QGIS 3.44, opens in 3.34 and newer
- `data.gpkg`: table `observations`, Point, EPSG:2056, fields `species`, `count`, `note`, `photo`, no rows
- form: `species` value map (marmot, ibex, chamois, golden eagle, other), `count` range 1 to 100, `photo` attachment stored relative to the project

Copy the folder to `~/workshop_mm_laax/laax-survey`, open the project in QGIS, continue at "Push it" in module 04.

Rebuild from scratch with PyQGIS: the widget setup lives in the project file, `unzip -p laax-survey.qgz laax-survey.qgs | grep editWidget`.
