'''
Drop empty columns and unneeded rows from partially cleaned and formatted covid-
death data.
'''

import csv

with open(r'covid_death_not_clean.csv','r') as csv_file,open('covid_deaths_final.csv', 'w',newline='') as covid:


 csv_reader = csv.reader(csv_file, delimiter = ',')
 csv_writer = csv.writer(covid, delimiter=',')


 #get headers

 headers = next(csv_reader)
 headers = headers[:10]
 csv_writer.writerow(headers)

 for row in csv_reader:
    if row[3] < '2021-02-01' and row[3] > '2020-02-20':
        csv_writer.writerow(row[:10])