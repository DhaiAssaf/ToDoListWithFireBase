//
//  UpdateCategory.swift
//  ToDoListWithFireBase
//
//  Created by Dhai Alassaf on 27/04/2024.
//

import SwiftUI

struct UpdateCategory: View {
    @State private var categoryTitle = ""
    @State private var showingError = false
    @Environment(\.dismiss) var dismiss
    @EnvironmentObject private var firebaseManager: FirebaseManager
    var category: Category
    var body: some View {
        NavigationStack {
            Form {
                Section{
                        TextField("Category" , text: $categoryTitle)
                    } footer: {
                        Text(showingError ? "Title can not be empty!" :"Edit Category title").foregroundStyle(showingError ? .red : .gray)
                    }
                
                Section() {
                    Button("Update Category") {
                        if !categoryTitle.isEmpty {
                            let cat = Category(id: category.id, name: categoryTitle, itemsCounter: category.itemsCounter)
                            Task {
                                firebaseManager.updateCategory(cat)
                                try? await firebaseManager.fetchCategory()
                            }
                            dismiss()
                        } else {
                            showingError.toggle()
                        }
                        }
                            .frame(maxWidth: .infinity)
                    
                }}
            .navigationTitle("Update Category")
            Spacer()
            .onAppear {
                categoryTitle = category.name
                
            }
        }
    }
}

#Preview {
    UpdateCategory(category: Category(id: "", name: "", itemsCounter: 0))
        .environmentObject(FirebaseManager())
}
