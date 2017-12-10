# MovieBingo
**(Please open MovieBingo.xcworkspace to build the project)**

MovieBingo is a p2p (peer to peer) social network app that allows you to find someone nearby to watch a movie together. By register with MovieBingo, users can select a movie, and then the app will search out all other users who want to watch the same movie. 

# What I have done:

1, Configurating the CocoaPods. I have installed 6 Pods in my project:
  pod 'SwiftSoup': Pure Swift HTML Parser. For grabbing data from IMDB website
  pod 'Firebase/Core': Firebase Service basis
  pod 'Firebase/Auth': Firebase Authentification for user login and register
  pod 'Firebase/Database':  Firebase database for storing user data
  pod 'Firebase/Storage': Firebase Storage space for storing user avatar.
  pod 'JSQMessagesViewController' : An elegant messages UI library for iOS. Allow real time chat between users.
  
2, User login and register, including forget password and reset the password. Users can specify their name, age, sex, and upload an image as their avatars.

3, After logging in, you can see movies from IMDB website. When you click one of them, it lists all details about that movie.

4, You can see your user profile by clicking the icon on the right of the navigation bar, the icon on the left is for keeping track of recently chat users.

5, User can search nearby people according to the radius from their current location. The location of users will update per 15 mins on the server. (I have not implemented the search by age and sex feature yet !!!)

6, User can start a real time chat when the app finds a user nearby, the recent chat will be kept and user can find this chat by clicking the icon on the left of the movie view's navigation bar.

7, Connect the movie with the recent user search. Add a movie favourite list feature and app can match users if they have the same movie in both of their favourite list. Also implemented the search by age and sex feature.

8, user profile and nearby people profile
# What I am gonna do next:

1, Add an detailed appointment view so that user can specify when and which cinema they meet, which movie they will watch. User can access this view by clicking a button on the user in search results or in the recent chat.

2, Change the avatar and zoom in/out the avatar

3, A map view enables user to navigate the nearby cinema.

