private string function tailHibernateLog() {
	var javaLoader = application.javaLoader.init([expandpath("/libs/commons-io-2.4.jar")]);
	
	// get the Logger instance and the appender for finding reference to the file
	var logger = createObject("java", "org.apache.log4j.LogManager").getLogger("org.hibernate");
	var appender = logger.getAppender("HIBERNATECONSOLE");
	
	// StringBuilder for building the output
	var logLines = createObject("java",  "java.lang.StringBuilder").init();
	
	try {
		if (!structKeyExists(local, "appender")) {
			throw (message="Unable to read Hibernate configuration file. Appender not found",
				   type="LoggerNotFoundException");	
		}
		
		// force the appender's buffer to flush
		immediateFlush = appender.getImmediateFlush();
		appender.setImmediateFlush(true);
		logger.info("FLUSH");
		appender.setImmediateFlush(immediateFlush);
		
		var logFilePath = appender.getFile();
		var logFile = createObject("java", "java.io.File").init(logFilePath);
		var defaultCharset = createObject("java", "java.nio.charset.Charset").forName("UTF-8");
		var lineSep = createObject("java", "java.lang.System").getProperty("line.separator");
		
		var reader = javaLoader.create("org.apache.commons.io.input.ReversedLinesFileReader").init(logFile);
		var line = reader.readLine();
		
		// match these values in the log
		var rgx = "([0-9]{2}\/[0-9]{2})\s+((?:[0-1]?\d|2[0-3]):(?:[0-5]?\d):(?:[0-5]?\d))\s+(?:\[(tomcat\-ajp[^\]]+)\])";
		var pattern = createObject("java", "java.util.regex.Pattern").compile(rgx);
		var currentThreadName = createObject("java", "java.lang.Thread").currentThread().getName();
		var requestStart = request.requesttime;
		
		// read lines as they exist
		while (structKeyExists(local, "line")) {
			var matcher = pattern.matcher(line);
			// line must match the pattern
			if (matcher.find()) {	
							
				// group 0: full match
				// group 1: date
				// group 2: time
				// group 3: thread name
				var logDate = matcher.group(1);
				var logTime = matcher.group(2);
				var logThread = matcher.group(3);
				
				// timestamp of the log entry
				logDateTime = parseDateTime("#logDate#/#year(now())# #logTime#");
				
				// this log entry happened before the request started
				if (logDateTime.getTime() < dateAdd("s", -1, requeststart).getTime()) {
					break;
				}
				
				// match the log entry thread to the current thread
				if (logThread == currentThreadname) {
					logLines.insert(0, line);
					logLines.insert(0, lineSep & lineSep);
				}
			}
			line = reader.readLine();
		}
		
		reader.close();
		
		return logLines.toString().trim();
		
	} catch (java.io.FileNotFoundException e) {
		logLines.append("Unable to load file: #logFilepath#. The file does not exist.");
	} catch (any e) {
		logLines.append("Error: #e.message#");
	}
	
	return logLines.toString();
}
