## COMP90018 Mobile Computing Systems Programming Project Front-End

### Semester 2, 2017 - University of Melbourne

### Team
- Lisha Qiu
- Kai Zhang
- Yiqi Yu

### Structure of this project
- Front-End: iOS Application
- Back-End: Node.JS Application hosting on Heroku
- MongoDB Database and Face Recognition Service: Azure
- Details: Back-End server communicates with Azure face regonition services and mangage face database. Application managers could use it to update face database. It also connects with crime infomation database on Azure. Front-End sends requests to Back-End server to get related crime data and face identification results. 

### Development Environment
- Xcode 9.0
- Simulator: iOS 11

### Packages
- Azure Storage Client
- SwiftyJSON
- ESTabBarController-swift
- pop
- ImagePicker
- Piecharts
- SwiftyButton

### Main Function
- Query crime information based on user's location and presenting in two pie charts. One pie chart is for information in current location, the other is for average information. They show different type of cirmes with their counts and persentages. Based on these information, users could evaluate living conditions of current area.
- Idenfify criminals' faces. Users could take photos of people looks suspicious and search these faces in this face database. It would help people identify danger also help police search for wanted criminals.

