<?php

/** 
 * Implemnts hook_install_tasks
 */
function radix_hr_install_tasks($install_state) {
  return array(
    'radix_hr_set_default_language' => array(
      'display_name' => 'Standaardtaal instellen',
      'display' => TRUE,
      'type' => 'normal',
      'run' => INSTALL_TASK_RUN_IF_NOT_COMPLETED,
    ),
    'radix_hr_add_homepage' => array(
      'display_name' => 'Maak een homepage',
      'display' => TRUE,
      'type' => 'normal',
      'run' => INSTALL_TASK_RUN_IF_NOT_COMPLETED,
    ),
    'radix_hr_import_vocabularies_batch' => array(
      'display_name' => 'Importeer termen voor job velden',
      'type' => 'batch',
    ),
    'radix_hr_extra_configurations' => array(
      'display_name' => 'Extra configuraties',
      'display' => TRUE,
      'type' => 'normal',
      'run' => INSTALL_TASK_RUN_IF_NOT_COMPLETED,
    ),
  );
}

/**
 * Implements hook_form_FORM_ID_alter().
 *
 * Allows the profile to alter the site configuration form.
 */
function radix_hr_form_install_configure_form_alter(&$form, $form_state) {
  // Add checkbox for example content.
  $form['radix_hr'] = array(
    '#type' => 'fieldset',
    '#collapsible' => FALSE,
    '#title' => t('Radix HR Platform'),
  );

  $form['radix_hr']['radix_hr_demo_terms'] = array(
    '#type' => 'checkbox',
    '#title' => t('Installeer demo taxonomie-termen'),
    '#description' => t('Dit installeert een aantal standaard mogelijkheden op vlak van diploma, werkdomein...'),
    '#default_value' => FALSE,
  );

  $form['#submit'][] = 'radix_hr_install_configure_form_submit';
}

/**
 * Submit function for the altered install_configure_form
 */
function radix_hr_install_configure_form_submit(&$form, &$form_state) {
  // Set variable to install or not demo content.
  variable_set('radix_hr_install_demo_terms', $form_state['values']['radix_hr_demo_terms']);
}


/** 
 * Callback for task "set default language"
 */
function radix_hr_set_default_language(&$install_state) {
  // set Dutch as default language
  $languages = language_list();
  variable_set('language_default', $languages['nl']);
}


/**
 * Callback for task "add homepage"
 */
function radix_hr_add_homepage(&$install_state) {

	$bodytext = "Homepage";
	
	$node = new stdClass(); // Create a new node object
	$node->type = "page"; // Or page, or whatever content type you like
	node_object_prepare($node); // Set some default values
	
	$node->title    = "Homepage";
	//$node->language = LANGUAGE_NONE; // Or e.g. 'en' if locale is enabled
        $node->language = 'nl';

	$node->uid = 1; // UID of the author of the node; or use $node->name
	
	$node->body[$node->language][0]['value']   = $bodytext;
	$node->body[$node->language][0]['summary'] = text_summary($bodytext);
	$node->body[$node->language][0]['format']  = 'filtered_html';
	
	$node->path = array('alias' => 'home');
	
	if($node = node_submit($node)) { // Prepare node for saving
    node_save($node);
	}  

  variable_set('site_frontpage', 'node/1');
}

/**
 * Callback for task "import terms"
 */
function radix_hr_import_vocabularies_batch() {
  if (variable_get('radix_hr_install_demo_terms', FALSE)) {
	  $batch = array(
	    'title' => t('Importing taxonomy terms'),
	    'operations' => array(
	      array('radix_hr_import_vocabularies', array()),
	    ),
	    'finished' => 'radix_hr_import_vocabularies_finished',
	    'title' => t('Import terms'),
	    'init_message' => t('Starting import.'),
	    'progress_message' => t('Processed @current out of @total.'),
	    'error_message' => t('Recruiter vocabularies import batch has encountered an error.'),
	    'file' => drupal_get_path('profile', 'radix_hr') . '/radix_hr.install_vocabularies.inc',
	  );
	  return $batch;
  }
  
  variable_del('radix_hr_install_demo_terms');
}



/**
 * Callback for task "extra configurations"
 */
function radix_hr_extra_configurations(&$install_state) {

  // extra variables to be set
  
  // autopath pattern for nodes
  variable_set('pathauto_node_pattern', '[node:title]');
  
  // default theme
  theme_enable(array('zen', 'radix'));
  variable_set('theme_default', 'radix');

  // webform variables: hide comments and submitted by text
  variable_set('comment_webform', 0);
  variable_set('node_submitted_webform', 0);
  
}
