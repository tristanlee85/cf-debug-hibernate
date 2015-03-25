<cfscript>
component {
	variables.instance = {};
	instance.logger = createObject("java", "org.apache.log4j.Logger");

	/**
	 * Gets the Hibernate logger (if available)
	 * @output false
	 * @return org.apache.log4j.Logger
	 */
	public any function getLogger (string name = "org.hibernate.SQL") {
		return instance.logger.getLogger(name);
	}

	/**
	 * Gets all appenders for the logger
	 * @output false
	 * @return Array<Appender>
	 */
	public array function getAllAppenders () {
		var ar = [];
		var appenders = getLogger().getAllAppenders();

		while(appenders.hasMoreElements()) {
			arrayAppend(ar, appenders.nextElement());
		}

		return ar;
	}
}
</cfscript>