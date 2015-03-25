<cfscript>
component{
	// Application properties
	this.name = hash( getCurrentTemplatePath() );
	this.sessionManagement = true;
	this.sessionTimeout = createTimeSpan(1,0,0,0);
	this.setClientCookies = true;

	// application mappings
	APP_ROOT_PATH = getDirectoryFromPath(getCurrentTemplatePath());
	this.mappings = {
		"/models" = "#APP_ROOT_PATH#models",
		"/ram" = "ram://"
	};

	// Datasource
	// Uses an embedded H2 database simulating MySQL (Railo)
	this.datasources["hibernatetest"] = {
		  class: 'org.h2.Driver'
		, connectionString: 'jdbc:h2:#APP_ROOT_PATH#db\HibernateTest;MODE=MySQL'
	};
	this.datasource = "hibernatetest";

	// ORM configuration
	this.ormEnabled 	  = true;
	this.ormSettings	  = {
		cfclocation = [ "/models" ],
		dbcreate = "update",
		logSQL = true,
		flushAtRequestEnd = false,
		autoManageSession = false,
		eventHandling =  true,
		skipCFCWithError = false
	};

	public boolean function onApplicationStart(){
		setupDB();

		return true;
	}

	public boolean function onRequestStart(string targetPage){
		// Hibernate logging utility
		request.hibernateLogging = createObject("HibernateLogging");
		
		// reload application
		if (structKeyExists(url, "reinit")) {
			// remove all appenders to this Logger
			request.hibernateLogging.detachAllRequestAppenders();
			
			ormReload();
			try { applicationStop();} catch (any e) {}

			writeOutput("Application reloaded. <a href='//#cgi.http_host##cgi.script_name#'>Continue...</a>");
			return false;
		}

		// debug output
		if (structKeyExists(url, "debug") && isBoolean(url.debug)) {
			// turn on debugging for 30 days
			if (url.debug) {
				session.debug.debugUntil = dateAdd("d", 30, now());

			// turn off debugging
			} else {
				session.debug.debugUntil = dateAdd("n", -1, now());
			}
		}

		// enable debugging for X minutes
		if (structKeyExists(url, "debugtime") && val(url.debugtime) > 0) {
			session.debug.debugUntil = dateAdd("n", val(url.debugtime), now());
		}
		
		// Attach an appender to the Hibernate logger for debugging
		request.hibernateLogging.attachRequestAppender();
		
		request.dsn = this.datasource;

		return true;
	}

	public void function onRequest (string targetPage) {
		// enable debug output
		setting showdebugoutput = session.debug.debuguntil > now();

		include targetPage;
	}

	public void function onRequestEnd(string targetPage) {
		// get the Hibernate logging appender and remove it from the logger
		var appender = request.hibernateLogging.getRequestAppender();
		request.hibernateLogging.detachRequestAppender();
		
		// get the logged events
		appender.getEvents();
	}

	public void function onSessionStart(){
		// debug session
		if (!structKeyExists(session, "debug")) {
			session.debug = {
				debuguntil = dateAdd("n", -1, now())
			};
		}
	}

	public void function onSessionEnd(struct sessionScope, struct appScope ){
	}

	private void function setupDB () {

	}
}
</cfscript>
