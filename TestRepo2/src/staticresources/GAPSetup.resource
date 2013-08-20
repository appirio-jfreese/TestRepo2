var MAX_RECORDS_ALLOWED = 5000;

var filterState;
var filterType;
var filterPriority;
var filterDueDate;
var filterRecType;
var filterName;

var loadProgress;

var goalHash;
var lineIndex;

var dataView;
var data;
var grid;
var columns;
var options;

var selectedGoal;

function Hash(){
    var lengthCounter = 0;
    var valueHolder = new Object();
    this.put = function(key, val){
    	if(valueHolder[key] == null){
    		lengthCounter++;
    	}
        valueHolder[key] = val;
    };
    this.remove = function(key){
    	delete valueHolder[key];
    }
    this.get = function(key) {
    	return valueHolder[key];
    };
    this.values = function(){
    	var arr = [];
    	for(var propString in valueHolder){
    		arr.push(valueHolder[propString]);
    	}
    	return arr;
    };
    this.length = function(){
        return lengthCounter;
    };
}

function applyFilters(state, type, priority, dueDate, recType, name){
	filterState = state;
	filterType = type;
	filterPriority = priority;
	filterDueDate = dueDate;
	filterRecType = recType;
	filterName = name;
	buildFilterQuery();
}

function buildFilterQuery(){
	var q = 'SELECT Id';
	q += ', Name';
	q += ', State__c';
	q += ', Goal_For__c';
	q += ', Goal_For__r.Name';
	q += ', Minimum_of_Accounts__c';
	q += ', Cases_Displayed__c';
	q += ', RecordTypeId';
	q += ', RecordType.Name';
	q += ', Priority__c';
	q += ', Due_Date__c';
	q += ', Completed__c';
	q += ', Parent_Goal__c';
	q += ', Parent_Goal__r.Parent_Goal__c';
	q += ', Goal_Level__c';
	q += ' FROM Goal__c';
	
	var dateSplit = filterDueDate.split('|');
	q += ' WHERE Due_Date__c >= ' + dateSplit[0];
	q += ' AND Due_Date__c < ' + dateSplit[1];
	
	if(filterState != 'Any'){
		q += ' AND State__c = \'' + filterState + '\'';
	}
	if(filterType != 'Any'){
		q += ' AND Goal_Type__c = \'' + filterType + '\'';
	}
	if(filterPriority != 'Any'){
		q += ' AND Priority__c = \'' + filterPriority + '\'';
	}
	if(filterRecType != 'Any'){
		q += ' AND RecordTypeId = \'' + filterRecType + '\'';
	}
	if(filterName != '' && filterName != null){
		q += ' AND Name LIKE \'%' + filterName + '%\'';
	}
	q += ' ORDER By Parent_Goal__r.Parent_Goal__c, Parent_Goal__c';
	
	//alert(q);
	
	performFilterQuery(q);
}

function performFilterQuery(queryString){
	Visualforce.remoting.Manager.invokeAction('GoalAdminController.performFilterQuery', queryString,
		function(result, event){
			if(result == null){
				alert('No results found. Please change your filter values and try again.');
				//closeLoadModal();
			} else if(result.length > MAX_RECORDS_ALLOWED){
				alert(result.length + ' records found (too many to display). Please change your filter values to be more specific, and try again.');
				//closeLoadModal();
			} else {
				processFilterQuery(result);
			}
		},
		{escape: true}
	);
}

function processFilterQuery(result){
	//process records
	var states = new Hash();
	var groups = new Hash();
	goalHash = new Hash();
	lineIndex = 0;
	
	for(var i = 0; i < result.length; i++){
		var d = result[i];
		var indent = 2;
		
		var glString;
		if(d.Goal_Level__c == 'Director'){
			glString = 'Dir';
		} else if(d.Goal_Level__c == 'Manager'){
			glString = 'Mgr';
		} else if(d.Goal_Level__c == 'Rep'){
			glString = 'Rep';
		}
		
		var nameString = d.Goal_For__r.Name + ' (' + glString + ')';
		var date = new Date(d.Due_Date__c);
		var dueDate = (date.getUTCMonth() + 1) + '/' + date.getUTCDate()  + '/' + date.getUTCFullYear();
		
		var state = d.State__c;
		if(states.get(state) == null){
			var newState = {};
			newState.children = [];
			newState.nameString = state;
			newState.id = state;
			newState.parent = null;
			newState.indent = 0;
			newState._collapsed = false;
			states.put(state, newState);
		}
		
		var groupKey = d.State__c + '|' + d.Name + '|' + d.RecordTypeId + '|' + d.Due_Date__c;
		if(groups.get(groupKey) == null){
			var newGroup = {};
			newGroup.children = [];
			groups.put(groupKey, newGroup);
			newGroup.nameString = d.Name;
			newGroup.id = groupKey;
			newGroup.parent = states.get(d.State__c);
			newGroup.indent = 1;
			newGroup.recTypeName = d.RecordType.Name;
			newGroup.Priority__c = d.Priority__c;
			newGroup.dueDate = dueDate;
			newGroup._collapsed = false;
			states.get(d.State__c).children.push(newGroup);
		}
		
		var parent = null;
		if(d.Parent_Goal__c != null){
			indent++;
			parent = goalHash.get(d.Parent_Goal__c);
			if(parent != null){
				if(parent.children == null){
					parent.children = [];
				}
				parent.children.push(d);
			}
		}
		if(d.Parent_Goal__r != null && d.Parent_Goal__r.Parent_Goal__c != null){
			indent++;
		}
		if(parent == null){
			parent = groups.get(groupKey);
			parent.children.push(d);
		}
		
		d["id"] = d.Id;
		d["parent"] = parent;
		d["indent"] = indent;
		d["_collapsed"] = false;
		d["nameString"] = nameString;
		//d["recTypeName"] = d.RecordType.Name;
		//d["dueDate"] = dueDate;
		d.Priority__c = '';
		d["visible"] = true;
		
		goalHash.put(d.Id, d);
	}
	
	data = [];
	lineIndex = 0;
	var stateVals = states.values();
	stateVals.sort(nameCompare);
	for(var i = 0; i < stateVals.length; i++){
		addLineToData(stateVals[i]);
	}
	
	showGridBlock();
}

function nameCompare(a, b){
	if(a.nameString < b.nameString){
		return -1;
	} else if(a.nameString > b.nameString){
		return 1;
	}
	return 0;
}

function addLineToData(line){
	if(line != null){
		line.lineIndex = lineIndex;
		lineIndex++;
		
		if(line.parent != null){
			line.parent = line.parent.lineIndex;
		}
		
		data.push(line);
		
		if(line.children != null){
			line.children.sort(nameCompare);
			for(var i = 0; i < line.children.length; i++){
				addLineToData(line.children[i]);
			}
		}
	}
}

function applyFilterResult(){
	//create columns
	if(columns == null){
		columns = [
			{id: "dispNameCol", name: "Name", field: "nameString", width: 440, formatter: TaskNameFormatter},
			{id: "goalCol", name: "Goal", field: "Minimum_of_Accounts__c", width: 50, cssClass: "cell-right-align"},
			{id: "casesCol", name: "Cases", field: "Cases_Displayed__c", width: 50, cssClass: "cell-right-align", formatter: CasesFormatter},
			{id: "cascadedCol", name: "Cascaded", field: "Completed__c", width: 80, cssClass: "cell-center-align", formatter: CheckmarkFormatter},
			{id: "recTypeCol", name: "Record Type", field: "recTypeName", width: 140},
			{id: "priorityCol", name: "Priority", field: "Priority__c", width: 120},
			{id: "dueDateCol", name: "Due Date", field: "dueDate", width: 100}
			
		];
	}
	if(options == null){
		options = {
			editable: false,
			enableAddRow: false,
			enableCellNavigation: true,
			asyncEditorLoading: false
		};
	}
	
	
	dataView = new Slick.Data.DataView({ inlineFilters: true });
	
	dataView.getItemMetadata = function(index) {
		var item = dataView.getItem(index);
		if (item.indent == 0) {
	    	return {
				cssClasses: "stateRow"
			};
		} else if (item.indent == 1) {
	    	return {
				cssClasses: "groupRow"
			};
		}
	}
	
	dataView.beginUpdate();
	dataView.setItems(data);
	dataView.setFilter(myFilter);
	dataView.endUpdate();
	
	grid = new Slick.Grid("#goalGrid", dataView, columns, options);
	
	grid.setSelectionModel(new Slick.RowSelectionModel());
	
	grid.onCellChange.subscribe(function (e, args){
		dataView.updateItem(args.item.id, args.item);
	});
	
	grid.onClick.subscribe(function (e, args){
		if(j$(e.target).hasClass("toggle")) {
			var item = dataView.getItem(args.row);
			if(item) {
				if(!item._collapsed) {
					item._collapsed = true;
				} else {
					item._collapsed = false;
				}
				dataView.updateItem(item.id, item);
			}
			e.stopImmediatePropagation();
			selectNone();
			clearSelection();
		}
  	});
  	
  	dataView.onRowsChanged.subscribe(function (e, args) {
		grid.invalidateRows(args.rows);
		grid.render();
	});
	
	grid.onSelectedRowsChanged.subscribe(function() {
		selectedGoal = null;
		
		var selectedIndexes = grid.getSelectedRows();
		j$.each(selectedIndexes, function (index, value) {
			selectedGoal = dataView.getItem(value);
		});
		
		if(selectedGoal != null){
			if(selectedGoal.Id != null){
				goalSelected(selectedGoal.Id);
			} else if(selectedGoal.Priority__c != null){
				var ids = [];
				for(var i = 0; i < selectedGoal.children.length; i++){
					ids.push(selectedGoal.children[i].Id);
				}
				groupSelected(ids.join(','));
			} else {
				selectNone();
			}
		}
	});
}

function myFilter(item) {
	if(item.deleted == true){
		return false;
	}
	if(item.parent != null){
		var parent = data[item.parent];

		while(parent){
			if(parent._collapsed){
				return false;
			}

			parent = data[parent.parent];
		}
	}
	return true;
}

var TaskNameFormatter = function (row, cell, value, columnDef, dataContext) {
  //value = value.replace(/&/g,"&amp;").replace(/</g,"&lt;").replace(/>/g,"&gt;");
  var spacer = "<span style='display:inline-block;height:1px;width:" + (15 * dataContext["indent"]) + "px'></span>";
  var idx = dataView.getIdxById(dataContext.id);
  if (data[idx + 1] && data[idx + 1].indent > data[idx].indent) {
    if (dataContext._collapsed) {
      return spacer + " <span class='toggle expand'></span>&nbsp;" + value;
    } else {
      return spacer + " <span class='toggle collapse'></span>&nbsp;" + value;
    }
  } else {
    return spacer + " <span class='toggle'></span>&nbsp;" + value;
  }
};

function CasesFormatter(row, cell, value, columnDef, dataContext) {
	if(dataContext != null && dataContext.RecordType != null && dataContext.RecordType.Name != null){
		if(dataContext.RecordType.Name == 'Display Goals' || dataContext.RecordType.Name == 'Volume/QD Goals'){
			return value;
		}
		return '--';
	}
	return '';
}

function CheckmarkFormatter(row, cell, value, columnDef, dataContext){
	if(value == true){
		return 'X';
	}
	return '';
}

function expandAll(){
	for(var i = 0; i < data.length; i++){
		var item = data[i];
		if(item){
			item._collapsed = false;
		}
	}
	dataView.refresh();
}

function collapseAll(){
	var leng = dataView.getLength();
	for(var i = 0; i < leng; i++){
		var item = dataView.getItem(i);
		if(item){
			item._collapsed = true;
		}
	}
	dataView.refresh();
}

function deleteSelected(){
	var index = grid.getSelectedRows()[0];
	var item = dataView.getItem(index);
	item.deleted = true;
	
	deleteChildren(item);
	checkParent(item);
	
	dataView.refresh();
	clearSelection();
}

function deleteChildren(item){
	if(item.children != null){
		for(var i = 0; i < item.children.length; i++){
			var child = item.children[i];
			child.deleted = true;
			deleteChildren(child);
		}
	}
}

function checkParent(item){
	if(item.parent != null && item.Goal_Level__c == 'Director'){
		var parent = dataView.getItem(item.parent);
		var allDeleted = true;
		for(var i = 0; i < parent.children.length; i++){
			if(parent.children[i].deleted != true){
				allDeleted = false;
				i = parent.children.length;
			}
		}
		if(allDeleted){
			parent.deleted = true;
			//checkParent(parent);
		}
	}
}

function clearSelection(){
	grid.getSelectionModel().setSelectedRanges([{fromRow: -1, toRow:-1, fromCell: -1, toCell:-1}]);
	grid.resetActiveCell();
}


function applyGoalChanges(newMinimum, newCases){
	var index = grid.getSelectedRows()[0];
	var item = dataView.getItem(index);
	item.Minimum_of_Accounts__c = parseInt(newMinimum);
	item.Cases_Displayed__c = parseInt(newCases);
	dataView.refresh();
	grid.updateRow(index);

	grid.resetActiveCell();
}

function applyGroupChanges(newName, newDueDate, newPriority){
	var index = grid.getSelectedRows()[0];
	var item = dataView.getItem(index);
	item.nameString = newName;
	item.dueDate = newDueDate;
	item.Priority__c = newPriority;
	dataView.refresh();
	grid.updateRow(index);

	grid.resetActiveCell();
}





















