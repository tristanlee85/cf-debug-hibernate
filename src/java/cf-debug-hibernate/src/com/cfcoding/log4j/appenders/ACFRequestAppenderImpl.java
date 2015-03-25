package com.cfcoding.log4j.appenders;
import coldfusion.runtime.NeoPageContext;

/**
 *
 * @author Tristan Lee (tristanlee85@gmail.com)
 */
public class ACFRequestAppenderImpl extends RequestAppender {

    public ACFRequestAppenderImpl(NeoPageContext context) {
        super(context.getFusionContext().getCurrentUserThreadName(), context.getFusionContext().getStartTime().getTime());
    }
    
}
