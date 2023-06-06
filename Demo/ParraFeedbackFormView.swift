import SwiftUI

struct ParraFeedbackFormView: View {
    @State private var selectedType = ""
    @State private var feedbackText = ""
    
    let characterLimit = 500
    var characterCount: Int {
        feedbackText.count
    }
    
    var body: some View {
        NavigationView {
            VStack(alignment: .leading, spacing: 20) {
                VStack(alignment: .leading, spacing: 10) {
                    Text("We'd love to hear from you!")
                        .font(.subheadline).foregroundColor(.gray)
                }
                
                HStack {
                    Picker(selection: $selectedType, label: Text("Type of Feedback")) {
                        Text("General feedback").tag("General feedback")
                        Text("Share an Idea").tag("Share an Idea")
                        Text("Request a feature").tag("Request a feature")
                        Text("Bug Report").tag("Bug Report")
                        Text("Other").tag("Other")
                    }
                    .accentColor(.gray)
                    .pickerStyle(MenuPickerStyle())
                    
                    Spacer()
                }
                .padding()
                .background(.white)
                .clipShape(RoundedRectangle(cornerRadius: 8))
                .background(
                    RoundedRectangle(cornerRadius: 8)
                        .stroke(Color.gray, lineWidth: 1)
                )

                VStack(spacing: 5) {
                    VStack {
                        TextEditor(text: $feedbackText)
                            .frame(height: 200)
                        
                        
                    }
                    .padding()
                    .background(.white)
                    .clipShape(RoundedRectangle(cornerRadius: 8))
                    .background(
                        RoundedRectangle(cornerRadius: 8)
                            .stroke(Color.gray, lineWidth: 1)
                    )

                    HStack {
                        Spacer()
                        Text("\(characterCount)/\(characterLimit)")
                            .foregroundColor(characterCount > characterLimit ? .red : .secondary)
                            .padding(.trailing, 4)
                    }
                }
                
                Spacer()
                
                Button(action: submitFeedback) {
                    Text("Submit")
                        .font(.headline)
                        .foregroundColor(.white)
                        .frame(maxWidth: .infinity, minHeight: 50)
                        .background(Color.blue)
                        .cornerRadius(8)
                }
                .padding(.top, 16)
            }
            .navigationTitle("Leave Feedback")
            .padding()
            .background(Color(uiColor: .systemGroupedBackground))
        }
    }
    
    func submitFeedback() {
        // Add your implementation to handle the submission of feedback
        print("Submitting feedback...")
    }
}

struct ParraFeedbackFormView_Previews: PreviewProvider {
    static var previews: some View {
        ParraFeedbackFormView()
    }
}
