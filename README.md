## BTS Data Viewer

The Department of Transportation publishes data about how many seats and passengers every airline carries on every flight it operates.  (The data also include cargo capacity and load, but this project only focuses on seats and passengers.)

This project contains a primitive front end backed by a database.

### DB 28 Segment Data

The data set this project's goal is to elucidate is the DB 28 Segment Data, currently available here: https://www.bts.gov/browse-statistical-products-and-data/bts-publications/data-bank-28ds-t-100-domestic-segment-data.

This data provides the total available seats and passengers carried on every route by every airline.  This project throws out all data other than that for scheduled flights with passenger seats available.  
The data comes aggregated by operating airline and airplane type on a per-month basis.  Unfortunately, the data does not come with a key to disambiguate the marketing airline for regional flights operated on
behalf of legacy airlines.  

The DB 28 data is rather large and not checked in to version control.  To download it, reference the link above.  There is a smaller data set of aircraft types that is checked in to version control.  The source for
that data set is the old Transtats database: https://www.transtats.bts.gov/DL_SelectFields.aspx?gnoyr_VQ=GDD&QO_fu146_anzr=N8vn6v10%20f722146%20gnoyr5.  

### Usage

This project runs on rails.  Once you have it set up, you'll need to put the data into the database.  

1. First, go to the console and run `Data::InputAircraft.run` to load the CSV of aircraft data into the database.
1. Then, download the DB28 CSV file(s) of your choice and put them in the `data/bts` directory in this project.  Once they are there, you can run `Data::InputBts.run` in the rails console and the files will be
inserted into the database.  Using the .asc file extensions that come with the file downloads (as of July 2022) is fine.

To view the data in your browser, turn on the rails server and visit the page on localhost.  The primitive front end should be fairly intuitive.
