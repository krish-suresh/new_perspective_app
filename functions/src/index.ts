/* eslint-disable max-len */
import * as functions from "firebase-functions";
import * as admin from "firebase-admin";
admin.initializeApp();
export const createChat = functions.firestore.document("/chatSearch/searchingUsers").onUpdate( (change) => {
  const data = change.after.data();
  const listOfUsers: string[] = data.liveSearchingUsers;
  if (listOfUsers.length > 1) {
    functions.logger.log(listOfUsers.length);
    functions.logger.log("Test Log");
    const uid0 = listOfUsers[0];
    const uid1 = listOfUsers[1];
    const chat = {
      users: [uid0, uid1],
      createdAt: admin.database.ServerValue.TIMESTAMP,
      messages: [],
      usersTyping: {
        uid0: false,
        uid1: false,
      },
    };
    admin.firestore().collection("chats").add(chat);
    admin.firestore().doc("/chatSearch/searchingUsers").update({
      liveSearchingUsers: admin.firestore.FieldValue.arrayRemove([uid0, uid1]),
    });
  }
});
