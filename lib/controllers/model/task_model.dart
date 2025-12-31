class TaskModel {
  final String title;
  final String description;
  final String skill;
  final String duration;
  final String resourceType; 
  final String resourceUrl;

  const TaskModel({
    this.title = '',
    this.description = '',
    this.skill = '',
    this.duration = '',
    this.resourceType = 'none',
    this.resourceUrl = '',
  });

  TaskModel copyWith({
    String? title,
    String? description,
    String? skill,
    String? duration,
    String? resourceType,
    String? resourceUrl,
  }) {
    return TaskModel(
      title: title ?? this.title,
      description: description ?? this.description,
      skill: skill ?? this.skill,
      duration: duration ?? this.duration,
      resourceType: resourceType ?? this.resourceType,
      resourceUrl: resourceUrl ?? this.resourceUrl,
    );
  }
}
