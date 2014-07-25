itemFile='doff.txt';
settings.path_items='1_experiment/';
[allItems,columnNames]=tdfimport([settings.path_items itemFile]);
[a b]=test(allItems.experiment)
