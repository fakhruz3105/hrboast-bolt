// Update the handleSubmitResponse function
const handleSubmitResponse = async (responseText: string) => {
  try {
    const { error } = await supabase
      .from('warning_letters')
      .update({
        show_cause_response: responseText,
        response_submitted_at: new Date().toISOString()
      })
      .eq('id', letter.id); // Use letter.id directly instead of content.warning_letter_id

    if (error) throw error;

    setResponse({
      text: responseText,
      submitted_at: new Date().toISOString()
    });
    setShowForm(false);
  } catch (error) {
    console.error('Error submitting response:', error);
    alert('Failed to submit response. Please try again.');
  }
};