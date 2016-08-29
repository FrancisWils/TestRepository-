//
//  Clustering.swift
//  clustering
//
//  Created by Vincent on 8/1/16.
//  Copyright © 2016 Vincent. All rights reserved.
//

import Foundation
import CoreLocation
import MapKit

class Clustering {
    

    
   
    
    var data_dict: [String:Int] = [
        "msg_id" : 0,
        "lat" : 1,
        "lon" : 2,
        "tag" : 3
    ]
    
    var cluster_stack = [Message]()
    var message_array = [Message]()
    var radius = Float()
    var tag_summary_data_dict = [String: Int]()
    
    var true_statement1:Bool
    var true_statement2:Bool
    
    var dist_sum:Float

    
    var potential_centroid_index = Int()
    var num_clusters = Int()
    var distance = Float()
    var cluster_id = Int()
    
    var clustered_message_array = [Message]()
    
    var centroid_array = [Message]()
    
    var cluster_stacks = [Message]()
    var workingStack = [Message]()
    
    var potential_centroid = Message()

    
    
    init (message_array: [Message], radius: Float) {
        
      
        
        self.message_array = message_array
        self.radius = radius
        
        
        self.tag_summary_data_dict = [String: Int]()

        self.true_statement1 = Bool(false)
        self.true_statement2 = Bool(false)

        
        self.dist_sum = Float()

        
        
        self.num_clusters = Int()
        self.distance = Float()
        self.cluster_id = Int()
        
        self.clustered_message_array = [Message]()
        self.centroid_array = [Message]()
        
        self.cluster_stacks = [Message]()
        self.workingStack = [Message]()
        
        self.potential_centroid = Message()
        
        self.find_clusters_by_tag()
        
        self.find_centroids()
        
        
    }
    



    
   
    func summarize_tags_by_count() {
    
        // Error Check
        
        /*
        guard (!self.message_array.isEmpty) else {
            
            let rr_error: RR_Error = RR_Error(error_num: 200, error_desc: "Message array is empty")
            print(rr_error.long_error)
            return

        }
        */
        
        // Read message_array
        for message in self.message_array {
            // Increment County By Tag
            if (self.tag_summary_data_dict[message.tag] != nil) {
                //print(message.tag, "data dict tag")
                self.tag_summary_data_dict[message.tag]! += 1
                
            } else {
                //print(message.tag, "data dict tag")
                self.tag_summary_data_dict[message.tag] = 1
                
            }
    
        }
        
        
        for key in self.tag_summary_data_dict {
            
            print("Key:", key)
        }
    
    }

        
    func find_clusters_by_tag() {
        
        self.summarize_tags_by_count()
        
        self.cluster_id = 0

        
        // For each key in tag_summary_data_dict
        for key in self.tag_summary_data_dict {
        
            var message_stack = [Message]()
            
            //print("Key:", key)
            
        
            // For each message; check tag and create a message stack
            // The message_stack is going to be passed to find_clusters() to determine first pass clusters
            for message in self.message_array {
                
                if message.tag == key.0 {
                
                    message_stack.append(message)
                
                    
                    // let object = message
                    
                    // print ("Tag - Message:", object.msg_id, object.lat, object.lon, object.tag)
                    
                    
                }
        
            }
            self.workingStack = message_stack
            
            find_clusters(message_stack)
            
        }
                

    
    }
        
    func find_clusters(message_stack: [Message]) {
    
        
        var stack : [Message] = message_stack
        
        print("Stack Count:", stack.count)
        
        while (stack.count > 0) {
        
            stack = filter_within_radius(stack, radius: self.radius, identifier: self.cluster_id)
        
            self.cluster_id += 1
        
        }
        
        return
        
    }



    func filter_within_radius(main_working_stack:[Message], radius: Float, identifier: Int) -> [Message] {
    
        // print "Remaining:", len(stack)

        var in_cluster = 0
        var out_cluster = 0

        var temp_stack = [Message]()
        // var temp_cluster_stack = [Message]()

        var row_cntr = 0
        
        var lat1 = Float()
        var lon1 = Float()
        var lat2 = Float()
        var lon2 = Float()
        // var tag = String()

        for value in main_working_stack {
            

            row_cntr += 1

            if row_cntr == 1 {
                
                
                lat1 = value.lat
                lon1 = value.lon

                lat2 = lat1
                lon2 = lon1
                
                
            }
            else {

                lat2 = value.lat
                lon2 = value.lon

            }
            
            
            
         
        
            let distance = self.calculate_distance(lat1, lon1: lon1, lat2: lat2,lon2: lon2)
            
            
            
            value.cluster_id = identifier
            self.num_clusters = identifier + 1
            
            value.distance = distance
            
            if distance < self.radius {
                in_cluster += 1
                self.clustered_message_array.append(value)
                
                
                // print("Value:", value.msg_id, value.distance)
            
            // print "In Cluster:", identifier, lat1, lon1, lat2, lon2, distance, "meters"
            }
            else {
                out_cluster += 1
                temp_stack.append(value)
            
                //print "Out Cluster:", lat1, lon1, lat2, lon2, distance
            
            }
            
            // print("In/Out:", in_cluster, out_cluster)

            // temp_stack contains out_cluster messages
            
        
        
        }
        
        
        return temp_stack


    }
    
    
    func calculate_distance(lat1: Float, lon1: Float, lat2: Float, lon2: Float) -> Float {
        
        /*
        CLLocationCoordinate2D { guard let location = value as? NSDictionary, let latitude = (location["lat"] ?? location["latitude"]) as? Double, let longitude = (location["lng"] ?? location["longitude"]) as? Double else { throw MapperError() }
        */
        
        
        
        let pointOne = CLLocationCoordinate2D(latitude: Double(lat1), longitude: Double(lon1))
        let pointTwo = CLLocationCoordinate2D(latitude: Double(lat2), longitude: Double(lon2))
        
        
        let mapPoint1 = MKMapPointForCoordinate(pointOne)
        let mapPoint2 = MKMapPointForCoordinate(pointTwo)
        
        let distance = MKMetersBetweenMapPoints(mapPoint1, mapPoint2)
        
        return Float(distance)
    }
    
  
    func find_centroids() {
        
        
        if self.clustered_message_array.isEmpty == true {

            return
        }
        
        
        
        self.centroid_array = [Message]()
        
        
        var i = 0
        

        
        while i < self.num_clusters {
            
            var cluster_stack = [Message]()
            
            for message in self.clustered_message_array {
                
                
                if message.cluster_id == i {
                    cluster_stack.append(message)
                    
                    let object:Message = message
                    
                    print("Cluster Stack:", object.msg_id, object.lat, object.lon, object.tag, object.cluster_id, object.distance)

                    
                    
                }
            
            
            }
            
            i += 1
            
            
            let lowest_point:Message = self.calculate_lowest_cost(cluster_stack)
            
            self.centroid_array.append(lowest_point)
            
        }

        
        print("Centroid Array Count:", centroid_array.count)
        
        return
    }

    
    func calculate_lowest_cost(cluster_stack: [Message]) -> Message {
    
    
        // for each cluster stack, iterate through for each point;
        // take sum of distances of each point against potential centroid point
        var work_stack = [Message]()
        var work_cluster = [Message]()
        
        
        work_stack = cluster_stack
        work_cluster = cluster_stack
    
        /*
        for point in cluster_stack {
            
            /*
            let object: Message = point
            print("Cluster_Stack Message:", object.msg_id, object.lat, object.lon, object.tag, object.cluster_id, object.distance)
            */
            
           

    
        }
        */
    
        var i = 0
        var lowest_dist_sum:Float = 0
    
        var potential_centroid = Message()
        var lowest_point = Message()
    
        while (!work_stack.isEmpty) {
            
            print("Work Stack Count:", work_stack.count)
            
            potential_centroid = work_stack.popLast()!
            
            // let object: Message = potential_centroid
            // print("Potential Centroid:", object.msg_id, object.lat, object.lon, object.tag, object.cluster_id, object.distance)

            
      
            
    
            i += 1
    
            let lat1 = (potential_centroid.lat)!
            let lon1 = (potential_centroid.lon)!
    
            var dist_sum:Float = 0
            
    
            
            for point in work_cluster {
                
                let lat2 = Float(point.lat)
                let lon2 = Float(point.lon)
    
                if lat1 == lat2 && lon1 == lon2 {
    
                    distance = 0
    
                } else {
                    
    
                    distance = self.calculate_distance(lat1, lon1: lon1, lat2: lat2, lon2: lon2)
                    dist_sum += distance
            
                }
                
           
                
            }
            
            
            
            let potential_centroid_index:Int = self.findIndex(potential_centroid)
            self.clustered_message_array[potential_centroid_index].cost = dist_sum
            
            
            potential_centroid.cost = dist_sum
            
            if (lowest_dist_sum == 0 || dist_sum < lowest_dist_sum) {
                
                lowest_dist_sum = dist_sum
                
                lowest_point = potential_centroid
                
            }

            
            
        }
        
    
        return lowest_point

    
    }
    
    
    func findIndex(potential_centroid: Message) -> Int {
        

        var potential_centroid_index = -1
        
        for (index, point) in EnumerateSequence(self.clustered_message_array) {
           

            potential_centroid_index = index
           
            
            if (potential_centroid.msg_id == point.msg_id) {
                
                print("Potential_centroid_index:", potential_centroid_index)
                
                potential_centroid_index = index

            }
            
        }
        
        return potential_centroid_index
        
    }
    
    
    func find_average(cluster_stacks: [Message]){
        var total_lat:Float = 0.0
        var total_lon: Float = 0.0
        for cluster_stack in cluster_stacks {
        total_lon = cluster_stack.lon + total_lon
        total_lat = cluster_stack.lat + total_lat
        

        }
        print("Cluster Average:", total_lat/Float(cluster_stacks.count),",",total_lon/Float(cluster_stacks.count))
        
    }
    
    

    
}

