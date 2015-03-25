<cfscript>

propPath = "C:\Users\tlee04\.CommandBox\lib\log4j.properties";
configurator = createObject("java", "org.apache.log4j.PropertyConfigurator");
configurator.configure(propPath);

loggers = createObject("java", "org.apache.log4j.LogManager").getCurrentLoggers();

while(loggers.hasMoreElements()) {
	logger = loggers.nextElement();
	parent = logger.getParent();

	appenders = logger.getAllAppenders();
	writeoutput("#logger.getName()# (#parent.getName()#)<br>");

	while (appenders.hasMoreElements()) {
		appender = appenders.nextElement();

		if (len(appender.getName()) > 0) {
			writeoutput("&nbsp;&nbsp;&nbsp;- #appender.getName()# - #appender.getTarget()#<br />");
		}
	}
}

/*
server.scope (root)
server.deploy (root)
server.thread (root)
org.hibernate (root)
   - HIBERNATECONSOLE - System.out
web.2e59f4276de7358dd391f1b2c6fcc59f.requesttimeout (root)
server.mapping (root)
server.search (root)
org.hibernate.cache (org.hibernate)
   - HIBERNATECONSOLE - System.out
server.gateway (root)
web.2e59f4276de7358dd391f1b2c6fcc59f.trace (root)
server.remoteclient (root)
server.memory (root)
web.2e59f4276de7358dd391f1b2c6fcc59f.application (root)
web.2e59f4276de7358dd391f1b2c6fcc59f.gateway (root)
web.2e59f4276de7358dd391f1b2c6fcc59f.scheduler (root)
web.2e59f4276de7358dd391f1b2c6fcc59f.mail (root)
web.2e59f4276de7358dd391f1b2c6fcc59f.scope (root)
org.apache.axis.enterprise (root)
   - CONSOLE - System.out
web.2e59f4276de7358dd391f1b2c6fcc59f.remoteclient (root)
server.orm (root)
web.2e59f4276de7358dd391f1b2c6fcc59f.exception (root)
org.hibernate.tool.hbm2ddl (org.hibernate)
   - HIBERNATECONSOLE - System.out
web.2e59f4276de7358dd391f1b2c6fcc59f.orm (root)
server.rest (root)
*/
</cfscript>