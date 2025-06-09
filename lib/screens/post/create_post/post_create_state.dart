import 'dart:io';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:zic_flutter/core/models/community.dart';
import 'package:zic_flutter/core/providers/post_creation_notifier.dart.dart';

// Clasa de stare care va conține toate câmpurile formularului
class PostCreationState {
  // Câmpuri pentru formular
  final TextEditingController textController;
  final FocusNode textFocusNode; 
  final TextEditingController urlController;
  final List<TextEditingController> optionControllers; // Pentru poll
  final List<File> images; // Pentru media
  final String selectedPostType; // 'text', 'link', 'poll', 'media'
  final String selectedAudience; // 'friends', 'community_id'
  final Community? selectedCommunity; // Detaliile comunității selectate
  final bool anonymousPost;

  // Starea operațiunilor
  final bool isLoading;
  final String? validationMessage;
  final bool isValid;

  PostCreationState({
    required this.textController,
    required this.textFocusNode,
    required this.urlController,
    required this.optionControllers,
    required this.images,
    required this.selectedPostType,
    required this.selectedAudience,
    this.selectedCommunity,
    required this.anonymousPost,
    this.isLoading = false,
    this.validationMessage,
    this.isValid = false,
  });


  // Metoda copyWith pentru a crea o nouă instanță de stare cu modificări
  PostCreationState copyWith({
    TextEditingController? textController,
    FocusNode? textFocusNode,
    TextEditingController? urlController,
    List<TextEditingController>? optionControllers,
    List<File>? images,
    String? selectedPostType,
    String? selectedAudience,
    Community? selectedCommunity,
    bool? anonymousPost,
    bool? isLoading,
    String? validationMessage, // Nullable, so pass directly
    bool? isValid,
  }) {
    return PostCreationState(
      // Reutilizăm controlerele existente dacă nu sunt furnizate altele noi
      textController: textController ?? this.textController,
      textFocusNode: textFocusNode ?? this.textFocusNode,
      urlController: urlController ?? this.urlController,
      optionControllers: optionControllers ?? this.optionControllers,
      images: images ?? this.images,
      selectedPostType: selectedPostType ?? this.selectedPostType,
      selectedAudience: selectedAudience ?? this.selectedAudience,
      selectedCommunity: selectedCommunity ?? this.selectedCommunity,
      anonymousPost: anonymousPost ?? this.anonymousPost,
      isLoading: isLoading ?? this.isLoading,
      validationMessage: validationMessage,
      isValid: isValid ?? this.isValid,
    );
  }

  // Metodă pentru a dispune controlerele atunci când starea nu mai este necesară
  void dispose() {
    textController.dispose();
    textFocusNode.dispose(); 
    urlController.dispose();
    for (final controller in optionControllers) {
      controller.dispose();
    }
    // Nu dispunem de images, deoarece acestea sunt File-uri, nu controlere
  }

  // Metodă pentru a reseta starea la valorile inițiale
  PostCreationState reset() {
    dispose(); // Dispune controlerele vechi
    return PostCreationState(
      textController: TextEditingController(),
      textFocusNode: FocusNode(), // FocusNode pentru text
      urlController: TextEditingController(),
      optionControllers: [TextEditingController(), TextEditingController()],
      images: [],
      selectedPostType: 'text',
      selectedAudience: 'friends',
      selectedCommunity: null,
      anonymousPost: false,
      isLoading: false,
      validationMessage: null,
      isValid: false,
    );
  }

  static PostCreationState initial() {
    return PostCreationState(
      textController: TextEditingController(),
      textFocusNode: FocusNode(), // FocusNode pentru text
      urlController: TextEditingController(),
      optionControllers: [TextEditingController(), TextEditingController()],
      images: [],
      selectedPostType: 'text',
      selectedAudience: 'friends',
      selectedCommunity: null,
      anonymousPost: false,
      isLoading: false,
      validationMessage: null,
      isValid: false,
    );
  }
}

final postCreationNotifierProvider = StateNotifierProvider.autoDispose<PostCreationNotifier, PostCreationState>(
  (ref) => PostCreationNotifier(ref)
);