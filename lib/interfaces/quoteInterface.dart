



import 'package:cloud_firestore/cloud_firestore.dart';

class ExploreQuote{
  final Map<String, dynamic> quoteData;
  final String quote;
  final Timestamp time;
  final String uid;

  ExploreQuote(this.quoteData, {this.quote, this.time, this.uid});

  factory ExploreQuote.fromJson(Map<String, dynamic> quoteData) {
    ExploreQuote quote = ExploreQuote(
      quoteData,
      quote: quoteData['quote'],
      time: quoteData['time'],
      uid: quoteData['uid'],
    );
    return quote;
  }

  Map<String, dynamic> toJson() {
    return {
      'quote': quote, // TODO add more fields
      'time': time,
      'uid': uid,
    };
  }
}