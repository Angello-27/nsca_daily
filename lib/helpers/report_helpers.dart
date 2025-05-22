// lib/helpers/report_helpers.dart

/// Grupo étnico de estudiantes
Map<String, String> getEthnicGroups() {
  return {
    'White': 'White',
    'Black': 'Black or African American',
    'Hispanic': 'Hispanic or Latino',
    'Asian': 'Asian',
    'Indian': 'American Indian',
    'Unsure': 'Unsure',
  };
}

/// Grupos de profesores y personal
Map<String, String> getFacultyOrStaffGroups() {
  return {
    'Administrators': 'Administrators / Leadership',
    'Teachers': 'Teachers',
    'Support': 'Support / Other Staff',
    'Counselors': 'Counselors or Specialists',
  };
}

/// Resultados (outcomes)
Map<String, String> getOutcomes({bool excelView = false}) {
  return {
    'outcome01': 'Prayer',
    'outcome02': 'Scripture references',
    'outcome03': 'Ongoing caregiving support from a chaplain',
    'outcome04': 'No further action required',
    'outcome05': 'Referral to a mental health professional',
    'outcome06': 'Referral to another ministry or religious group',
    'outcome07': 'Referral to a human resource organization',
    'outcome08': 'Home / hospital or other visit',
    'outcome09': 'Religious Services & Invocations',
    'outcome10':
        '“MUST REPORT”'
        ' - linked to a detailed report form',
  };
}

/// Temas de discusión (students o teachers)
Map<String, String> getDiscussionTopics({bool forTeacher = false}) {
  final data = <String, String>{
    'topic01': 'Bullying / harassment / violence',
    'topic02': 'Friendship / peer issues',
    'topic03': 'Trauma / anxiety / depression',
    'topic04': 'Identity issues',
    'topic05':
        forTeacher
            ? 'Family breakdown / family conflict'
            : 'Family breakdown / parental separation / family conflict',
    'topic06':
        forTeacher ? 'Administration issues' : 'School disciplinary actions',
    'topic07': 'Behavior / self-control',
    'topic08': 'Issue(s) with a teacher or coach',
    'topic09': 'Alcohol or drugs',
    'topic10': 'Racism',
    'topic11': 'Gender confusion',
    'topic12': 'Motivation',
    'topic13': 'Confidence / self-respect',
    'topic14':
        forTeacher ? 'Performance / expectations' : 'Grades / school work',
    'topic15': 'Abuse / harm / suicide',
  };
  if (!forTeacher) {
    data['topic16'] = 'Issue(s) at home';
    data['topic17'] = 'Issues with students, parents or other staff';
    data['topic18'] = 'Issues with the law';
  }
  return data;
}

/// Porcentajes en temas
Map<String, String> getPercentageOnTopics() {
  return {
    'topics01': 'Social, emotional mental support',
    'topics02': 'Spiritual support (prayer and scripture references)',
    'topics03': 'Role modelling and mentoring',
    'topics04': 'Educational support',
    'topics05': 'Extra-curricular activities',
    'topics06': 'Team contributions',
    'topics07': 'Community development',
  };
}

/// Tipos de crisis
Map<String, String> getCrisisTypes() {
  return {
    'crisis01': 'Natural Disasters',
    'crisis02': 'Violence / Death / Accidents',
    'crisis03': 'Health Emergencies',
    'crisis04': 'Technical, Engineering Failures or Hazardous Materials',
    'crisis05': 'Community Crises',
    'crisis06': 'Mental or Physical Health Threats',
    'crisis07': 'Student Abuse',
  };
}

/// Opciones de calificación (rating)
Map<String, String> getRatingOptions() {
  return {
    'highly_dissatisfied': 'Highly Dissatisfied',
    'dissatisfied': 'Dissatisfied',
    'neither': 'Neither Dissatisfied or Satisfied',
    'satisfied': 'Satisfied',
    'highly_satisfied': 'Highly Satisfied',
  };
}

/// Opciones de recomendación (Net Promoter Score)
Map<String, String> getRecommendationOptions() {
  return {
    'not_at_all_likely': 'Not At All Likely',
    'not_very_likely': 'Not Very Likely',
    'somewhat_likely': 'Somewhat Likely',
    'likely': 'Likely',
    'highly_likely': 'Highly Likely',
  };
}
