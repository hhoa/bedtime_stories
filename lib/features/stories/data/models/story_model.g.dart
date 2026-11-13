// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'story_model.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

ChoiceOptionModel _$ChoiceOptionModelFromJson(Map<String, dynamic> json) =>
    ChoiceOptionModel(
      id: json['id'] as String,
      kind: json['kind'] as String,
      icon: json['icon'] as String?,
      label: Map<String, String>.from(json['label'] as Map),
      next: json['next'] as String,
      answer: json['answer'] as String?,
    );

Map<String, dynamic> _$ChoiceOptionModelToJson(ChoiceOptionModel instance) =>
    <String, dynamic>{
      'id': instance.id,
      'kind': instance.kind,
      'icon': instance.icon,
      'label': instance.label,
      'next': instance.next,
      'answer': instance.answer,
    };

CueModel _$CueModelFromJson(Map<String, dynamic> json) => CueModel(
  word: json['word'] as String,
  part: json['part'] as String,
  action: json['action'] as String,
  pose: json['pose'] as String?,
  to: (json['to'] as List<dynamic>?)
      ?.map((e) => (e as num).toDouble())
      .toList(),
  at: (json['at'] as num?)?.toDouble(),
);

Map<String, dynamic> _$CueModelToJson(CueModel instance) => <String, dynamic>{
  'word': instance.word,
  'part': instance.part,
  'action': instance.action,
  'pose': instance.pose,
  'to': instance.to,
  'at': instance.at,
};

StoryNodeModel _$StoryNodeModelFromJson(Map<String, dynamic> json) =>
    StoryNodeModel(
      id: json['id'] as String,
      type: json['type'] as String,
      image: json['image'] as String,
      text: Map<String, String>.from(json['text'] as Map),
      next: json['next'] as String?,
      offerRewindTo: json['offer_rewind_to'] as String?,
      options: (json['options'] as List<dynamic>?)
          ?.map((e) => ChoiceOptionModel.fromJson(e as Map<String, dynamic>))
          .toList(),
      sticker: json['sticker'] as String?,
      ambient: json['ambient'] as String?,
      ambientOrigin: (json['ambient_origin'] as List<dynamic>?)
          ?.map((e) => (e as num).toDouble())
          .toList(),
      cues: (json['cues'] as Map<String, dynamic>?)?.map(
        (k, e) => MapEntry(
          k,
          (e as List<dynamic>)
              .map((e) => CueModel.fromJson(e as Map<String, dynamic>))
              .toList(),
        ),
      ),
      poses: (json['poses'] as Map<String, dynamic>?)?.map(
        (k, e) => MapEntry(k, e as String),
      ),
      counted: (json['counted'] as Map<String, dynamic>?)?.map(
        (k, e) => MapEntry(k, e as String),
      ),
    );

Map<String, dynamic> _$StoryNodeModelToJson(StoryNodeModel instance) =>
    <String, dynamic>{
      'id': instance.id,
      'type': instance.type,
      'image': instance.image,
      'text': instance.text,
      'next': instance.next,
      'offer_rewind_to': instance.offerRewindTo,
      'options': instance.options,
      'sticker': instance.sticker,
      'ambient': instance.ambient,
      'ambient_origin': instance.ambientOrigin,
      'cues': instance.cues,
      'poses': instance.poses,
      'counted': instance.counted,
    };

StoryModel _$StoryModelFromJson(Map<String, dynamic> json) => StoryModel(
  id: json['id'] as String,
  theme: json['theme'] as String,
  section: json['section'] as String?,
  hero: json['hero'] as String,
  title: Map<String, String>.from(json['title'] as Map),
  cover: json['cover'] as String,
  start: json['start'] as String,
  nodes: (json['nodes'] as List<dynamic>)
      .map((e) => StoryNodeModel.fromJson(e as Map<String, dynamic>))
      .toList(),
  math: json['math'] as Map<String, dynamic>?,
);

Map<String, dynamic> _$StoryModelToJson(StoryModel instance) =>
    <String, dynamic>{
      'id': instance.id,
      'theme': instance.theme,
      'section': instance.section,
      'hero': instance.hero,
      'title': instance.title,
      'cover': instance.cover,
      'start': instance.start,
      'nodes': instance.nodes,
      'math': instance.math,
    };
