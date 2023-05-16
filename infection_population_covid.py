'''
Reading the cleaned covid csv file about infection cases and death. Then 
using pandas and numpy libraries to calculate the percent of population infected with covid by 
date and location
'''

# import libraries

import pandas as pd
import numpy as np

# convert csv to pandas library
covid_reader_df = pd.read_csv("covid_deaths_final.csv")


#drop all the columns that I don't need-
#and save result to new dataframe

# print(covid_reader_df.columns)
covid_df =  (covid_reader_df.loc[:,covid_reader_df.columns.isin(['iso_code','continent','location',\
                                                                    'date','total_cases','population'])]).copy()
# print(covid_df.columns)

#calculate percent of population infected with covid by 
#date and location. Then save it to new column in dataframe
covid_df['infection_percent'] = np.where(covid_df["population"]>0, covid_df["total_cases"]/covid_df["population"],np.nan)


#write result dataframe to csv
covid_df.to_csv('infect_pop_covid.csv',index=False)
