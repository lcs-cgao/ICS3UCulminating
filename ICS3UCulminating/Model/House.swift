//
//  House.swift
//  ICS3UCulminating
//
//  Created by GaoZiHan on 2026/6/4.
//

import Foundation

// MODEL
struct House: Identifiable {
    
    // MARK: Stored properties
    // Stored properties must be provided with a value by providing an argument when creating an instance of this structure, or, be initialized with a default value
    
    // Unique identifier to conform to Identifiable protocol
    // This is initialized with a default value
    let id = UUID()

    // Name of the house
    let name: String

    // Description of house
    let description: String

    // Image of house
    let image: String
    
    // MARK: Computed properties
    // Computed properties calculate or derive a value using stored properties
    
    // MARK: Functions
    // Functions take action using information provided through parameters

}

// Create several instances of the House structure
let ross = House(name: "Ross", description: "Opened in October 2022, Ross House is named in honor of the Ross Family for their significant contributions to LCS. This house is part of a modern double residence designed to foster a sense of community on campus.", image: "")
 
let parent = House(name: "Parent", description: "Also inaugurated in 2022, Parent House recognizes the Parent Family's leadership and philanthropy. It was named in gratitude for their transformative support of the school community.", image: "")
 
let ryder = House(name: "Ryder", description: "Named after Tom Ryder, an alumnus of LCS ('53), Ryder House emphasizes the importance of tradition and community among its residents.", image: "")
 
let ondaatje = House(name: "Ondaatje", description: "Named after Sri Lankan-Canadian author Michael Ondaatje, this house symbolizes the diverse and creative spirit nurtured within the school.", image: "")
 
let moodie = House(name: "Moodie", description: "This house, led by dedicated staff, aims to instill independence and global citizenship among its residents.", image: "")
 
let memorial = House(name: "Memorial", description: "A historical residence honoring LCS alumni who served in significant capacities.", image: "")
 
let uplands = House(name: "Uplands", description: "Uplands House is deeply rooted in fostering outdoor education and community bonding, reflective of its leadership's passion for outdoor learning.", image: "")
 
let cooper = House(name: "Cooper", description: "Named to honor longstanding contributions to the school, Cooper House is a space of growth and challenge for students.", image: "")
 
let matthews = House(name: "Matthews", description: "Named for its connection to a storied past at LCS, Matthews House blends tradition with modern residential life.", image: "")
 
let grove = House(name: "Grove", description: "As a nod to the school's nickname, 'The Grove,' Grove House celebrates its rich natural surroundings and strong community spirit.", image: "")
 
let rashleigh = House(name: "Rashleigh", description: "Rashleigh House integrates its history with a vibrant student community, led by alumni deeply connected to the school.", image: "")
 
let colebrook = House(name: "Colebrook", description: "This house's design and ethos reflect the natural beauty and community focus of LCS.", image: "")
 
let wadsworth = House(name: "Wadsworth", description: "A residence honoring a significant legacy within LCS, fostering inclusivity and strong relationships among students.", image: "")

// Create an array containing the instances above
let exampleHouseList = [
    ross,
    parent,
    ryder,
    ondaatje,
    moodie,
    memorial,
    uplands,
    cooper,
    matthews,
    grove,
    rashleigh,
    wadsworth,
]
