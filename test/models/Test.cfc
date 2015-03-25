<cfscript>
component persistent="true" table="Test" {
	property name="ID" fieldType="id" generator="uuid";
	property name="columnA";
	property name="columnB";
	property name="createdOn" ormtype="timestamp";
	property name="updatedOn" ormtype="timestamp";
	
	public void function preInsert () {
		setCreatedOn(now());	
	}
	
	public void function preUpdate () {
		setUpdatedOn(now());	
	}
}
</cfscript>