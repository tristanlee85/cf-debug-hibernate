package com.cfcoding.log4j.appenders;

import java.util.ArrayList;
import org.apache.log4j.AppenderSkeleton;
import org.apache.log4j.spi.LoggingEvent;

/**
 * The {@link RequestAppender} collects events as they are logged within the request.
 * <p>
 * Because logging is asynchronous across multiple threads (requests), it's
 * important that only events within a specific thread are collected. {@link org.apache.log4j.spi.LoggingEvent events}
 * are logged within a thread name and timestamp. That event information is compared
 * against the thread and time reference specified in the constructor so only logs
 * specific to the current request are collected.
 * </p>
 * <p>
 * <b>Important:</b> As this appender is specific to a thread, the thread will eventually
 * terminate and the appender no longer valid (unless a new thread comes along with
 * the same name). This appender should be removed (via {@link org.apache.log4j.Logger#removeAppender(org.apache.log4j.Appender)} manually once the request has
 * completed or no more logging is necessary for this appender.
 * </p>
 * @author Tristan Lee (tristanlee85@gmail.com)
 */
public abstract class RequestAppender extends AppenderSkeleton  {
    private final Thread thread;
    private final long startTime;
    private final ArrayList<LoggingEvent> eventsList = new ArrayList();
    
    /**
     * Constructs a new appender specific to events logged in the thread
     * and after the specified time
     * @param thread thread to capture events within
     * @param time reference in which events this time should be consumed
     */
    public RequestAppender(Thread thread, long time) {
        super();
        
        this.thread = thread;
        this.startTime = time;
        
        setName(thread.getName().concat(String.valueOf(time)));
    }
    
    /**
     * Constructs a new appender specific to events logged in the {@linkplain Thread} threadName
     * and after the specified time. This constructor traverses up the
     * {@link java.lang.ThreadGroup thread groups}, enumerating all active threads to find a matching
     * name. It is recommended to use the {@link #RequestAppender(java.lang.Thread, long)} constructor
     * if reference to the thread is available.
     * @param threadName name of the {@link java.lang.Thread thread} to capture events within
     * @param time reference in which events this time should be consumed
     */
    public RequestAppender(String threadName, long time) {
        super();
        
        ThreadGroup currentThreadGroup = Thread.currentThread().getThreadGroup();
        Thread requestThread = null;
        
        Thread[] allThreads = null;
        
        // get the root ThreadGroup
        while (currentThreadGroup.getParent() != null) {
            currentThreadGroup = currentThreadGroup.getParent();
        }
        
        // get all active threads
        currentThreadGroup.enumerate(allThreads, true);
        
        // find the thread matching the specified name
        for (Thread t : allThreads) {
            if (t.getName().equals(threadName)) {
                requestThread = t;
                break;
            }
        }
        
        this.thread = requestThread;
        this.startTime = time;
        
        setName(thread.getName().concat(String.valueOf(time)));
    }

    /**
     * Appends this event to the internal list of captured events if the event
     * is logged within the appender's thread and after the reference time
     * @param le 
     */
    @Override
    protected void append(LoggingEvent le) {
        if (le.getThreadName().equals(this.thread.getName()) && le.getTimeStamp() >= this.startTime) {
            this.eventsList.add(le);
        }
    }

    @Override
    public void close() {
    }

    @Override
    public boolean requiresLayout() {
        return false;
    }
    
    /**
     * Gets all of the {@linkplain LoggingEvent events} consumed by this appender
     * @return
     */
    public ArrayList<LoggingEvent> getEvents () {
        return this.eventsList;
    }
    
}
