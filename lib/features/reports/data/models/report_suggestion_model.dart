import '../../domain/entities/report_suggestion.dart';
import 'json_parsing.dart';

class ReportSuggestionModel extends ReportSuggestion {
  const ReportSuggestionModel({required super.id, required super.name});

  factory ReportSuggestionModel.fromJson(Map<String, dynamic> json) {
    return ReportSuggestionModel(
      id: jsonString(json['id']),
      name: jsonString(json['name']),
    );
  }
}
