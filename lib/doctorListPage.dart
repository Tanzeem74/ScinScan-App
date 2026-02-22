import 'package:flutter/material.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

class DoctorListPage extends StatefulWidget {
  const DoctorListPage({super.key});

  @override
  State<DoctorListPage> createState() => _DoctorListPageState();
}

class _DoctorListPageState extends State<DoctorListPage> {
  // reading data form database
  final Stream<List<Map<String, dynamic>>> _doctorStream = Supabase
      .instance
      .client
      .from('doctors')
      .stream(primaryKey: ['id']);

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text("Skin Specialists"),
        backgroundColor: const Color(0xFF008080),
        elevation: 0,
      ),
      body: Container(
        decoration: BoxDecoration(color: Colors.grey[100]),
        child: StreamBuilder<List<Map<String, dynamic>>>(
          stream: _doctorStream,
          builder: (context, snapshot) {
            // loding when data load
            if (snapshot.connectionState == ConnectionState.waiting) {
              return const Center(
                child: CircularProgressIndicator(color: Color(0xFF008080)),
              );
            }

            if (!snapshot.hasData || snapshot.data!.isEmpty) {
              return const Center(
                child: Text(
                  "No doctors found in your area.",
                  style: TextStyle(fontSize: 16, color: Colors.grey),
                ),
              );
            }

            final doctors = snapshot.data!;

            return ListView.builder(
              padding: const EdgeInsets.all(15),
              itemCount: doctors.length,
              itemBuilder: (context, index) {
                final doctor = doctors[index];

                return Card(
                  elevation: 2,
                  margin: const EdgeInsets.only(bottom: 15),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(15),
                  ),
                  child: Padding(
                    padding: const EdgeInsets.all(12),
                    child: Row(
                      children: [
                        CircleAvatar(
                          radius: 35,
                          backgroundColor: Colors.teal.withOpacity(0.1),
                          backgroundImage: doctor['image_url'] != null
                              ? NetworkImage(doctor['image_url'])
                              : null,
                          child: doctor['image_url'] == null
                              ? const Icon(
                                  Icons.person,
                                  size: 35,
                                  color: Colors.teal,
                                )
                              : null,
                        ),
                        const SizedBox(width: 15),

                        // doctor details
                        Expanded(
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text(
                                doctor['name'] ?? "Unknown Doctor",
                                style: const TextStyle(
                                  fontSize: 18,
                                  fontWeight: FontWeight.bold,
                                ),
                              ),
                              Text(
                                doctor['specialty'] ?? "Dermatologist",
                                style: const TextStyle(
                                  color: Colors.teal,
                                  fontWeight: FontWeight.w500,
                                ),
                              ),
                              const SizedBox(height: 5),
                              Row(
                                children: [
                                  const Icon(
                                    Icons.location_on,
                                    size: 14,
                                    color: Colors.grey,
                                  ),
                                  const SizedBox(width: 4),
                                  Text(
                                    doctor['location'] ?? "Not specified",
                                    style: const TextStyle(color: Colors.grey),
                                  ),
                                ],
                              ),
                            ],
                          ),
                        ),

                        // call button
                        IconButton(
                          icon: const Icon(
                            Icons.phone_in_talk,
                            color: Colors.green,
                          ),
                          onPressed: () {
                            ScaffoldMessenger.of(context).showSnackBar(
                              SnackBar(
                                content: Text(
                                  "Calling ${doctor['contact']}...",
                                ),
                              ),
                            );
                          },
                        ),
                      ],
                    ),
                  ),
                );
              },
            );
          },
        ),
      ),
    );
  }
}
