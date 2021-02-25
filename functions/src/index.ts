/* eslint-disable max-len */
/* eslint linebreak-style: ["error", "windows"]*/
import * as functions from "firebase-functions";
import * as admin from "firebase-admin";
admin.initializeApp();
export const createChat = functions.firestore.document("/chatSearch/searchingUsers").onUpdate( (change) => {
  const data = change.after.data();
  const listOfUsers: string[] = data.liveSearchingUsers;
  functions.logger.log(listOfUsers.toString());
  if (listOfUsers.length > 1) {
    const uid0: string = listOfUsers[0];
    const uid1: string = listOfUsers[1];
    const users: string[] = [uid0, uid1];
    try {
      const chat = {
        users: users,
        createdAt: admin.firestore.FieldValue.serverTimestamp(),
        disabledAt: null,
        messages: [],
        usersTyping: {
          [uid0]: false,
          [uid1]: false,
        },
      };
      admin.firestore().collection("chats").add(chat);
      admin.firestore().doc("/chatSearch/searchingUsers").update({
        liveSearchingUsers: admin.firestore.FieldValue.arrayRemove(uid0),
      });
      admin.firestore().doc("/chatSearch/searchingUsers").update({
        liveSearchingUsers: admin.firestore.FieldValue.arrayRemove(uid1),
      });
    } catch (e) {
      functions.logger.log(e);
    }
  }
});
