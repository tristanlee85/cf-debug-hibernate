<cfscript>	
	// create
	transaction {
		oTest = new models.Test();
		oTest.setColumnA("Foo");
		oTest.setColumnB("Bar");
		entitySave(oTest);
		ormFlush();
	}
	
	// read
	lastTest = ormExecuteQuery("FROM Test ORDER BY createdOn DESC LIMIT 1", true);
	
	// update
	transaction {
		lastTest.setColumnB("Baz");	
	}
	
	// delete
	transaction {
		entityDelete(lastTest);	
	}	
</cfscript>