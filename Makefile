gen-proto:
	echo "Building Proto"
	protoc --proto_path=./../protobuf --swift_opt=Visibility=Public --swift_out=./"Mane HKU"/"Mane HKU"/pb --grpc-swift_opt=Visibility=Public --grpc-swift_out=./"Mane HKU"/"Mane HKU"/pb main_service.proto
	protoc --proto_path=./../protobuf --swift_opt=Visibility=Public --swift_out=./"Mane HKU"/"Mane HKU"/pb --grpc-swift_opt=Visibility=Public --grpc-swift_out=./"Mane HKU"/"Mane HKU"/pb health_check.proto
	protoc --proto_path=./../protobuf --swift_opt=Visibility=Public --swift_out=./"Mane HKU"/"Mane HKU"/pb --grpc-swift_opt=Visibility=Public --grpc-swift_out=./"Mane HKU"/"Mane HKU"/pb init_service.proto