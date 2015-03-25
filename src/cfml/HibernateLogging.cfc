<cfscript>
component {
	isACF = listFindNoCase("Railo,Lucee", server.coldfusion.productName) == 0;
	
	logManager = createObject("java", "org.apache.log4j.LogManager");
	loggerName = isACF ? "org.hibernate.SQL" : "org.hibernate";

	/**
	 * Gets the Hibernate logger (if available)
	 * @output false
	 * @return org.apache.log4j.Logger
	 */
	public any function getLogger (string name = loggerName) {
		// if the logger doesn't exist, try to load it from an available configurator
		if (isNull(logManager.exists(name))) {
			findConfigurator();
		}
		
		// return the instance of the logger, and a new instance of it doesn't exist
		return logManager.getLogger(name);
	}

	/**
	 * Gets all appenders for the logger
	 * @output false
	 * @return Array<org.apache.log4j.AppenderSkeleton>
	 */
	public array function getAllAppenders () {
		var ar = [];
		var appenders = getLogger().getAllAppenders();

		while(appenders.hasMoreElements()) {
			arrayAppend(ar, appenders.nextElement());
		}

		return ar;
	}
	
	/**
	 * Gets the RequestAppender to use for this Logger
	 * @output false
	 * @return com.cfcoding.log4j.appenders.RequestAppender
	 */
	public any function getRequestAppender () {
		if (!structKeyExists(variables, "requestAppender")) {
			if (isACF) {
				variables.requestAppender = createObject("java", "com.cfcoding.log4j.appenders.ACFRequestAppenderImpl").init(getPageContext());
			} else {
				variables.requestAppender = createObject("java", "com.cfcoding.log4j.appenders.RailoRequestAppenderImpl").init(getPageContext());
			}
		}
		
		return requestAppender;
	}
	
	/**
	 * Attaches the RequestAppender to the Logger if it doesn't already exist
	 * @output false
	 * @return void
	 */
	public void function attachRequestAppender () {
		var logger = getLogger();
		
		// ensure the appender hasn't already been attached
		var appender = logger.getAppender(getRequestAppender());
		
		if (!structKeyExists(local, "appender")) {
			logger.addAppender(getRequestAppender());
		}
	}
	
	/**
	 * Removes the RequestAppender from the Logger
	 * @output false
	 * @return void
	 */
	public void function detachRequestAppender () {
		var logger = getLogger();
		logger.removeAppender(getRequestAppender());
	}
	
	/**
	 * Removes all the RequestAppenders from the Logger
	 * @output false
	 * @return void
	 */
	public void function detachAllRequestAppenders () {
		var logger = getLogger();
		var appenders = logger.getAllAppenders();
		
		while (appenders.hasMoreElements()) {
			var appender = appenders.nextElement();
			
			try {
				appender.getEvents();
				logger.removeAppender(appender);
			} catch (any e) {}
		}
	}
	
	/**
	 * Loads the configurator for log4j
	 * @configurator {Array/String} path to configurator file
	 * @output false
	 * @return void
	 */
	public void function loadConfigurator (required any configurator) {
		var oConfigurator = createObject("java", "org.apache.log4j.PropertyConfigurator").init();
		
		if (isSimpleValue(configurator)) {
			configurator = listToArray(configurator);
		}
		
		if (!isArray(configurator)) {
			throw (message="Invalid CONFIGURATOR supplied.",
				   detail="The argument must be an Array or list of paths to a configurator file",
				   type="InvalidConfiguratorException");
		}
		
		// load the configurators
		for (var path in configurator) {
			oConfigurator.configure(path);	
		}
	}
	
	/**
	 * Attempts to load the log4j properties based off the class path of the Logger.
	 * It's assumed the log4j.properties file will reside in here.
	 * @output false
	 * @return void
	 */
	private void function findConfigurator () {
		var configurators = [];
		
		// Railo/Lucee
		if (!isAcf) {
			// we'll guess based off of the location of the LogManager
			try {
				var classDir = createObject("java", "java.io.File").init(logManager.getClass().getProtectionDomain().getCodeSource().getLocation().getFile()).getParentFile();
				var qProperties = directoryList(classDir, true, "query", "log4j.properties");
				
				for (var row in qProperties) {
					arrayAppend(configurators, "#row.directory#\#row.name#");	
				}
			// either no permission to search for the files or a property file isn't found
			} catch (any e) {
				writedump(e); abort;	
			}
			
		// ACF	
		} else {
			
		}
		
		loadConfigurator(configurators);		
	}
}
</cfscript>
