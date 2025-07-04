#' Takes a time series of type "Stationary around a linear trend", "Random walk with drift", or "Unit root and linear trend" and returns a time series that is "Stationary, no trend"
#'
#' @param x An object of class ts.
#' @param type Specifies the type of the time series.
#'   The options are: "Stationary around a linear trend", "Random walk with drift", "Unit root and linear trend", "Stationary, no trend"
#' @param pvalue Specifies the threshold for rejecting the null hypothesis after first differencing. The default is 0.05.
#' @param ic Lag selection based on "AIC" or "BIC". The default is "BIC". Used for DF testing after first differencing.
#' @returns A stationary, no trend series.
#' @examples
#' library(quantmod)
#' library(urca)
#' getSymbols("AAPL", src="yahoo")
#' type=unitRootDF_ABsequential(AAPL$AAPL.Close)
#' aapl_stationary=stationarize(ts(AAPL$AAPL.Close), type=type)



stationarize=function(x, type, pvalue=0.05, ic="BIC")
{
  if(type=="Random walk with drift")
  {
    ADF3=ur.df(diff(x), type = "drift", selectlags = "BIC")
    ADF3_stat=attributes(ADF3)$teststat[1] #the statistic of the test
    criticalValue_1=attributes(ADF3)$cval[1,1] #critical value at 1%
    criticalValue_5=attributes(ADF3)$cval[1,2] #critical value at 5%
    criticalValue_10=attributes(ADF3)$cval[1,3] #critical value at 10%

    if(pvalue==0.01)
    {
      criticalValue=criticalValue_1
    } else {
      if(pvalue==0.05)
      {
        criticalValue=criticalValue_5
      } else {
        criticalValue=criticalValue_10
      }
    }
    if(ADF3_stat>criticalValue)
    {
	ADF4=ur.df(diff(diff(x)), type = "drift", selectlags = "BIC")
    	ADF4_stat=attributes(ADF4)$teststat[1] #the statistic of the test
    	criticalValue_1=attributes(ADF4)$cval[1,1] #critical value at 1%
    	criticalValue_5=attributes(ADF4)$cval[1,2] #critical value at 5%
    	criticalValue_10=attributes(ADF4)$cval[1,3] #critical value at 10%

    	if(pvalue==0.01)
    	{
      		criticalValue=criticalValue_1
    	} else {
      		if(pvalue==0.05)
      		{
        		criticalValue=criticalValue_5
      		} else {
        		criticalValue=criticalValue_10
      		}
    	}
    	if(ADF4_stat>criticalValue)
    	{
	    print("First and second differences are not stationary. To continue, write code to test if the third difference is stationary.
			If it is, then <<x_stationary>> is third difference, otherwise 4th etc" )
	} else {
      		x_stationary=diff(diff(x))
      		intercept=c("NA")
      		betaTrend=c("NA")
	}
    } else {
      x_stationary=diff(x)
      intercept=c("NA")
      betaTrend=c("NA")
    }
  } else {
    if(type=="Stationary, no trend")
    {
      x_stationary=x
      intercept=c("NA")
      betaTrend=c("NA")
    } else {
      if(type=="Stationary around a linear trend")
      {
        trend=1:length(x)
        regression=lm(x~trend, data.frame(trend, x))
        x_stationary=regression$residuals
        #x_stationary=ts(x_stationary, start=c(yearStartSeries, quarterStartSeries), frequency=4)
        intercept=summary(regression)$coeff[1,1]
        betaTrend=summary(regression)$coeff[2,1]
      } else {
        if(type=="Unit root and linear trend")
        {
          trend=1:length(diff(x))
          regression=lm(diff(x)~trend, data.frame(trend, diff(x)))
          x_stat=regression$residuals
          #x_stat=ts(x_stat, start=c(yearStartSeries, (quarterStartSeries+1)), frequency=4)
          intercept=summary(regression)$coeff[1,1]
          betaTrend=summary(regression)$coeff[2,1]

          ADF3=ur.df(x_stat, type = "drift", selectlags = "BIC")
          ADF3_stat=attributes(ADF3)$teststat[1] #the statistic of the test
          criticalValue_1=attributes(ADF3)$cval[1,1] #critical value at 1%
          criticalValue_5=attributes(ADF3)$cval[1,2] #critical value at 5%
          criticalValue_10=attributes(ADF3)$cval[1,3] #critical value at 10%

          if(pvalue==0.01)
          {
            criticalValue=criticalValue_1
          } else {
            if(pvalue==0.05)
            {
              criticalValue=criticalValue_5
            } else {
              criticalValue=criticalValue_10
            }
          }
          if(ADF3_stat>criticalValue)
          {
		trend=1:length(diff(diff(x)))
          	regression=lm(diff(diff(x))~trend, data.frame(trend, diff(diff(x))))
          	x_stat_2=regression$residuals
          	#x_stat_2=ts(x_stat_2, start=c(yearStartSeries, (quarterStartSeries+1)), frequency=4)
          	intercept=summary(regression)$coeff[1,1]
          	betaTrend=summary(regression)$coeff[2,1]

          	ADF4=ur.df(x_stat_2, type = "drift", selectlags = "BIC")
          	ADF4_stat=attributes(ADF4)$teststat[1] #the statistic of the test
          	criticalValue_1=attributes(ADF4)$cval[1,1] #critical value at 1%
          	criticalValue_5=attributes(ADF4)$cval[1,2] #critical value at 5%
          	criticalValue_10=attributes(ADF4)$cval[1,3] #critical value at 10%

          	if(pvalue==0.01)
          	{
            		criticalValue=criticalValue_1
          	} else {
            		if(pvalue==0.05)
            		{
              			criticalValue=criticalValue_5
            		} else {
              			criticalValue=criticalValue_10
            		}
          	}
          	if(ADF4_stat>criticalValue)
          	{	  
            		print("First and second differences are not stationary. To continue, write code to test if third difference is stationary. ")
		} else {
			x_stationary=x_stat_2
		}
          } else {
            x_stationary=x_stat
          }
        } else {
          print("Write code to stationarize for the other non-stationary.")
        }
      }
    }
  }
 results_list=list(x_stationary, intercept, betaTrend)
 names(results_list)=c("x_stationary", "intercept", "betaTrend")
 return(results_list)
}
