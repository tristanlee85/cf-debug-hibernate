package com.cfcoding.log4j.appenders;
import railo.runtime.PageContext;

/**
 *
 * @author Tristan Lee (tristanlee85@gmail.com)
 */
public class RailoRequestAppenderImpl extends RequestAppender {

    public RailoRequestAppenderImpl(PageContext context) {
        super(context.getThread(), context.getStartTime());
    }    
}
