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
      // admin.firestore().collection("questions").wh TODO this needs to query for random question
      const chat = {
        users: users,
        createdAt: admin.firestore.FieldValue.serverTimestamp(),
        deletedAt: null,
        completedAt: null,
        liveAt: null,
        timeLimit: 300000,
        usersStatus: {
          [uid0]: "NORESPONSE",
          [uid1]: "NORESPONSE",
        },
        chatState: "CREATED",
        messages: [],
        usersTyping: {
          [uid0]: false,
          [uid1]: false,
        },
        question: {
          id: "9psFVZljDlbGDML02F5S",
          text: "What is the meaning of Life?",
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
