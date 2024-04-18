# GroupInbox-Admin

GroupInbox is a Flutter mobile application that reimagines email through subscription-based categorized messaging. Utilizing Firebase Authentication for secure access, and Firestore Database for real-time message and category management, it provides a streamlined communication platform for both admins and users.

## Features

- User Authentication: Secure login using Firebase Auth.
- Real-time Messaging: Instant message delivery categorized by user subscriptions with Firestore Database.
- Subscription Management: Users can subscribe or unsubscribe from categories to customize their message feed.

## Getting Started

Make sure you have Flutter installed on your machine and an emulator/device ready to run the app.

## Firestore Collections

- **Categories**: This collection stores different message categories. Each document represents a category with fields such as `ID` and `Name`.

- **Messages**: Contains the messages sent within each category. Each document has a 'id', `category`, `object`, and `body`, relating to its parent category by the category's name or ID.

## License

Distributed under the MIT License. See `LICENSE` for more information.

