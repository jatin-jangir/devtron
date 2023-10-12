// Code generated by protoc-gen-go-grpc. DO NOT EDIT.
// versions:
// - protoc-gen-go-grpc v1.2.0
// - protoc             v3.9.1
// source: api/helm-app/applist.proto

package client

import (
	context "context"
	grpc "google.golang.org/grpc"
	codes "google.golang.org/grpc/codes"
	status "google.golang.org/grpc/status"
)

// This is a compile-time assertion to ensure that this generated file
// is compatible with the grpc package it is being compiled against.
// Requires gRPC-Go v1.32.0 or later.
const _ = grpc.SupportPackageIsVersion7

// ApplicationServiceClient is the client API for ApplicationService service.
//
// For semantics around ctx use and closing/ending streaming RPCs, please refer to https://pkg.go.dev/google.golang.org/grpc/?tab=doc#ClientConn.NewStream.
type ApplicationServiceClient interface {
	ListApplications(ctx context.Context, in *AppListRequest, opts ...grpc.CallOption) (ApplicationService_ListApplicationsClient, error)
	GetAppDetail(ctx context.Context, in *AppDetailRequest, opts ...grpc.CallOption) (*AppDetail, error)
	GetAppStatus(ctx context.Context, in *AppDetailRequest, opts ...grpc.CallOption) (*AppStatus, error)
	Hibernate(ctx context.Context, in *HibernateRequest, opts ...grpc.CallOption) (*HibernateResponse, error)
	UnHibernate(ctx context.Context, in *HibernateRequest, opts ...grpc.CallOption) (*HibernateResponse, error)
	GetDeploymentHistory(ctx context.Context, in *AppDetailRequest, opts ...grpc.CallOption) (*HelmAppDeploymentHistory, error)
	GetValuesYaml(ctx context.Context, in *AppDetailRequest, opts ...grpc.CallOption) (*ReleaseInfo, error)
	GetDesiredManifest(ctx context.Context, in *ObjectRequest, opts ...grpc.CallOption) (*DesiredManifestResponse, error)
	UninstallRelease(ctx context.Context, in *ReleaseIdentifier, opts ...grpc.CallOption) (*UninstallReleaseResponse, error)
	UpgradeRelease(ctx context.Context, in *UpgradeReleaseRequest, opts ...grpc.CallOption) (*UpgradeReleaseResponse, error)
	GetDeploymentDetail(ctx context.Context, in *DeploymentDetailRequest, opts ...grpc.CallOption) (*DeploymentDetailResponse, error)
	InstallRelease(ctx context.Context, in *InstallReleaseRequest, opts ...grpc.CallOption) (*InstallReleaseResponse, error)
	UpgradeReleaseWithChartInfo(ctx context.Context, in *InstallReleaseRequest, opts ...grpc.CallOption) (*UpgradeReleaseResponse, error)
	IsReleaseInstalled(ctx context.Context, in *ReleaseIdentifier, opts ...grpc.CallOption) (*BooleanResponse, error)
	RollbackRelease(ctx context.Context, in *RollbackReleaseRequest, opts ...grpc.CallOption) (*BooleanResponse, error)
	TemplateChart(ctx context.Context, in *InstallReleaseRequest, opts ...grpc.CallOption) (*TemplateChartResponse, error)
	InstallReleaseWithCustomChart(ctx context.Context, in *HelmInstallCustomRequest, opts ...grpc.CallOption) (*HelmInstallCustomResponse, error)
	GetNotes(ctx context.Context, in *InstallReleaseRequest, opts ...grpc.CallOption) (*ChartNotesResponse, error)
	UpgradeReleaseWithCustomChart(ctx context.Context, in *UpgradeReleaseRequest, opts ...grpc.CallOption) (*UpgradeReleaseResponse, error)
	ValidateOCIRegistry(ctx context.Context, in *RegistryCredential, opts ...grpc.CallOption) (*OCIRegistryResponse, error)
}

type applicationServiceClient struct {
	cc grpc.ClientConnInterface
}

func NewApplicationServiceClient(cc grpc.ClientConnInterface) ApplicationServiceClient {
	return &applicationServiceClient{cc}
}

func (c *applicationServiceClient) ListApplications(ctx context.Context, in *AppListRequest, opts ...grpc.CallOption) (ApplicationService_ListApplicationsClient, error) {
	stream, err := c.cc.NewStream(ctx, &ApplicationService_ServiceDesc.Streams[0], "/ApplicationService/ListApplications", opts...)
	if err != nil {
		return nil, err
	}
	x := &applicationServiceListApplicationsClient{stream}
	if err := x.ClientStream.SendMsg(in); err != nil {
		return nil, err
	}
	if err := x.ClientStream.CloseSend(); err != nil {
		return nil, err
	}
	return x, nil
}

type ApplicationService_ListApplicationsClient interface {
	Recv() (*DeployedAppList, error)
	grpc.ClientStream
}

type applicationServiceListApplicationsClient struct {
	grpc.ClientStream
}

func (x *applicationServiceListApplicationsClient) Recv() (*DeployedAppList, error) {
	m := new(DeployedAppList)
	if err := x.ClientStream.RecvMsg(m); err != nil {
		return nil, err
	}
	return m, nil
}

func (c *applicationServiceClient) GetAppDetail(ctx context.Context, in *AppDetailRequest, opts ...grpc.CallOption) (*AppDetail, error) {
	out := new(AppDetail)
	err := c.cc.Invoke(ctx, "/ApplicationService/GetAppDetail", in, out, opts...)
	if err != nil {
		return nil, err
	}
	return out, nil
}

func (c *applicationServiceClient) GetAppStatus(ctx context.Context, in *AppDetailRequest, opts ...grpc.CallOption) (*AppStatus, error) {
	out := new(AppStatus)
	err := c.cc.Invoke(ctx, "/ApplicationService/GetAppStatus", in, out, opts...)
	if err != nil {
		return nil, err
	}
	return out, nil
}

func (c *applicationServiceClient) Hibernate(ctx context.Context, in *HibernateRequest, opts ...grpc.CallOption) (*HibernateResponse, error) {
	out := new(HibernateResponse)
	err := c.cc.Invoke(ctx, "/ApplicationService/Hibernate", in, out, opts...)
	if err != nil {
		return nil, err
	}
	return out, nil
}

func (c *applicationServiceClient) UnHibernate(ctx context.Context, in *HibernateRequest, opts ...grpc.CallOption) (*HibernateResponse, error) {
	out := new(HibernateResponse)
	err := c.cc.Invoke(ctx, "/ApplicationService/UnHibernate", in, out, opts...)
	if err != nil {
		return nil, err
	}
	return out, nil
}

func (c *applicationServiceClient) GetDeploymentHistory(ctx context.Context, in *AppDetailRequest, opts ...grpc.CallOption) (*HelmAppDeploymentHistory, error) {
	out := new(HelmAppDeploymentHistory)
	err := c.cc.Invoke(ctx, "/ApplicationService/GetDeploymentHistory", in, out, opts...)
	if err != nil {
		return nil, err
	}
	return out, nil
}

func (c *applicationServiceClient) GetValuesYaml(ctx context.Context, in *AppDetailRequest, opts ...grpc.CallOption) (*ReleaseInfo, error) {
	out := new(ReleaseInfo)
	err := c.cc.Invoke(ctx, "/ApplicationService/GetValuesYaml", in, out, opts...)
	if err != nil {
		return nil, err
	}
	return out, nil
}

func (c *applicationServiceClient) GetDesiredManifest(ctx context.Context, in *ObjectRequest, opts ...grpc.CallOption) (*DesiredManifestResponse, error) {
	out := new(DesiredManifestResponse)
	err := c.cc.Invoke(ctx, "/ApplicationService/GetDesiredManifest", in, out, opts...)
	if err != nil {
		return nil, err
	}
	return out, nil
}

func (c *applicationServiceClient) UninstallRelease(ctx context.Context, in *ReleaseIdentifier, opts ...grpc.CallOption) (*UninstallReleaseResponse, error) {
	out := new(UninstallReleaseResponse)
	err := c.cc.Invoke(ctx, "/ApplicationService/UninstallRelease", in, out, opts...)
	if err != nil {
		return nil, err
	}
	return out, nil
}

func (c *applicationServiceClient) UpgradeRelease(ctx context.Context, in *UpgradeReleaseRequest, opts ...grpc.CallOption) (*UpgradeReleaseResponse, error) {
	out := new(UpgradeReleaseResponse)
	err := c.cc.Invoke(ctx, "/ApplicationService/UpgradeRelease", in, out, opts...)
	if err != nil {
		return nil, err
	}
	return out, nil
}

func (c *applicationServiceClient) GetDeploymentDetail(ctx context.Context, in *DeploymentDetailRequest, opts ...grpc.CallOption) (*DeploymentDetailResponse, error) {
	out := new(DeploymentDetailResponse)
	err := c.cc.Invoke(ctx, "/ApplicationService/GetDeploymentDetail", in, out, opts...)
	if err != nil {
		return nil, err
	}
	return out, nil
}

func (c *applicationServiceClient) InstallRelease(ctx context.Context, in *InstallReleaseRequest, opts ...grpc.CallOption) (*InstallReleaseResponse, error) {
	out := new(InstallReleaseResponse)
	err := c.cc.Invoke(ctx, "/ApplicationService/InstallRelease", in, out, opts...)
	if err != nil {
		return nil, err
	}
	return out, nil
}

func (c *applicationServiceClient) UpgradeReleaseWithChartInfo(ctx context.Context, in *InstallReleaseRequest, opts ...grpc.CallOption) (*UpgradeReleaseResponse, error) {
	out := new(UpgradeReleaseResponse)
	err := c.cc.Invoke(ctx, "/ApplicationService/UpgradeReleaseWithChartInfo", in, out, opts...)
	if err != nil {
		return nil, err
	}
	return out, nil
}

func (c *applicationServiceClient) IsReleaseInstalled(ctx context.Context, in *ReleaseIdentifier, opts ...grpc.CallOption) (*BooleanResponse, error) {
	out := new(BooleanResponse)
	err := c.cc.Invoke(ctx, "/ApplicationService/IsReleaseInstalled", in, out, opts...)
	if err != nil {
		return nil, err
	}
	return out, nil
}

func (c *applicationServiceClient) RollbackRelease(ctx context.Context, in *RollbackReleaseRequest, opts ...grpc.CallOption) (*BooleanResponse, error) {
	out := new(BooleanResponse)
	err := c.cc.Invoke(ctx, "/ApplicationService/RollbackRelease", in, out, opts...)
	if err != nil {
		return nil, err
	}
	return out, nil
}

func (c *applicationServiceClient) TemplateChart(ctx context.Context, in *InstallReleaseRequest, opts ...grpc.CallOption) (*TemplateChartResponse, error) {
	out := new(TemplateChartResponse)
	err := c.cc.Invoke(ctx, "/ApplicationService/TemplateChart", in, out, opts...)
	if err != nil {
		return nil, err
	}
	return out, nil
}

func (c *applicationServiceClient) InstallReleaseWithCustomChart(ctx context.Context, in *HelmInstallCustomRequest, opts ...grpc.CallOption) (*HelmInstallCustomResponse, error) {
	out := new(HelmInstallCustomResponse)
	err := c.cc.Invoke(ctx, "/ApplicationService/InstallReleaseWithCustomChart", in, out, opts...)
	if err != nil {
		return nil, err
	}
	return out, nil
}

func (c *applicationServiceClient) GetNotes(ctx context.Context, in *InstallReleaseRequest, opts ...grpc.CallOption) (*ChartNotesResponse, error) {
	out := new(ChartNotesResponse)
	err := c.cc.Invoke(ctx, "/ApplicationService/GetNotes", in, out, opts...)
	if err != nil {
		return nil, err
	}
	return out, nil
}

func (c *applicationServiceClient) UpgradeReleaseWithCustomChart(ctx context.Context, in *UpgradeReleaseRequest, opts ...grpc.CallOption) (*UpgradeReleaseResponse, error) {
	out := new(UpgradeReleaseResponse)
	err := c.cc.Invoke(ctx, "/ApplicationService/UpgradeReleaseWithCustomChart", in, out, opts...)
	if err != nil {
		return nil, err
	}
	return out, nil
}

func (c *applicationServiceClient) ValidateOCIRegistry(ctx context.Context, in *RegistryCredential, opts ...grpc.CallOption) (*OCIRegistryResponse, error) {
	out := new(OCIRegistryResponse)
	err := c.cc.Invoke(ctx, "/ApplicationService/ValidateOCIRegistry", in, out, opts...)
	if err != nil {
		return nil, err
	}
	return out, nil
}

// ApplicationServiceServer is the server API for ApplicationService service.
// All implementations must embed UnimplementedApplicationServiceServer
// for forward compatibility
type ApplicationServiceServer interface {
	ListApplications(*AppListRequest, ApplicationService_ListApplicationsServer) error
	GetAppDetail(context.Context, *AppDetailRequest) (*AppDetail, error)
	GetAppStatus(context.Context, *AppDetailRequest) (*AppStatus, error)
	Hibernate(context.Context, *HibernateRequest) (*HibernateResponse, error)
	UnHibernate(context.Context, *HibernateRequest) (*HibernateResponse, error)
	GetDeploymentHistory(context.Context, *AppDetailRequest) (*HelmAppDeploymentHistory, error)
	GetValuesYaml(context.Context, *AppDetailRequest) (*ReleaseInfo, error)
	GetDesiredManifest(context.Context, *ObjectRequest) (*DesiredManifestResponse, error)
	UninstallRelease(context.Context, *ReleaseIdentifier) (*UninstallReleaseResponse, error)
	UpgradeRelease(context.Context, *UpgradeReleaseRequest) (*UpgradeReleaseResponse, error)
	GetDeploymentDetail(context.Context, *DeploymentDetailRequest) (*DeploymentDetailResponse, error)
	InstallRelease(context.Context, *InstallReleaseRequest) (*InstallReleaseResponse, error)
	UpgradeReleaseWithChartInfo(context.Context, *InstallReleaseRequest) (*UpgradeReleaseResponse, error)
	IsReleaseInstalled(context.Context, *ReleaseIdentifier) (*BooleanResponse, error)
	RollbackRelease(context.Context, *RollbackReleaseRequest) (*BooleanResponse, error)
	TemplateChart(context.Context, *InstallReleaseRequest) (*TemplateChartResponse, error)
	InstallReleaseWithCustomChart(context.Context, *HelmInstallCustomRequest) (*HelmInstallCustomResponse, error)
	GetNotes(context.Context, *InstallReleaseRequest) (*ChartNotesResponse, error)
	UpgradeReleaseWithCustomChart(context.Context, *UpgradeReleaseRequest) (*UpgradeReleaseResponse, error)
	ValidateOCIRegistry(context.Context, *RegistryCredential) (*OCIRegistryResponse, error)
	mustEmbedUnimplementedApplicationServiceServer()
}

// UnimplementedApplicationServiceServer must be embedded to have forward compatible implementations.
type UnimplementedApplicationServiceServer struct {
}

func (UnimplementedApplicationServiceServer) ListApplications(*AppListRequest, ApplicationService_ListApplicationsServer) error {
	return status.Errorf(codes.Unimplemented, "method ListApplications not implemented")
}
func (UnimplementedApplicationServiceServer) GetAppDetail(context.Context, *AppDetailRequest) (*AppDetail, error) {
	return nil, status.Errorf(codes.Unimplemented, "method GetAppDetail not implemented")
}
func (UnimplementedApplicationServiceServer) GetAppStatus(context.Context, *AppDetailRequest) (*AppStatus, error) {
	return nil, status.Errorf(codes.Unimplemented, "method GetAppStatus not implemented")
}
func (UnimplementedApplicationServiceServer) Hibernate(context.Context, *HibernateRequest) (*HibernateResponse, error) {
	return nil, status.Errorf(codes.Unimplemented, "method Hibernate not implemented")
}
func (UnimplementedApplicationServiceServer) UnHibernate(context.Context, *HibernateRequest) (*HibernateResponse, error) {
	return nil, status.Errorf(codes.Unimplemented, "method UnHibernate not implemented")
}
func (UnimplementedApplicationServiceServer) GetDeploymentHistory(context.Context, *AppDetailRequest) (*HelmAppDeploymentHistory, error) {
	return nil, status.Errorf(codes.Unimplemented, "method GetDeploymentHistory not implemented")
}
func (UnimplementedApplicationServiceServer) GetValuesYaml(context.Context, *AppDetailRequest) (*ReleaseInfo, error) {
	return nil, status.Errorf(codes.Unimplemented, "method GetValuesYaml not implemented")
}
func (UnimplementedApplicationServiceServer) GetDesiredManifest(context.Context, *ObjectRequest) (*DesiredManifestResponse, error) {
	return nil, status.Errorf(codes.Unimplemented, "method GetDesiredManifest not implemented")
}
func (UnimplementedApplicationServiceServer) UninstallRelease(context.Context, *ReleaseIdentifier) (*UninstallReleaseResponse, error) {
	return nil, status.Errorf(codes.Unimplemented, "method UninstallRelease not implemented")
}
func (UnimplementedApplicationServiceServer) UpgradeRelease(context.Context, *UpgradeReleaseRequest) (*UpgradeReleaseResponse, error) {
	return nil, status.Errorf(codes.Unimplemented, "method UpgradeRelease not implemented")
}
func (UnimplementedApplicationServiceServer) GetDeploymentDetail(context.Context, *DeploymentDetailRequest) (*DeploymentDetailResponse, error) {
	return nil, status.Errorf(codes.Unimplemented, "method GetDeploymentDetail not implemented")
}
func (UnimplementedApplicationServiceServer) InstallRelease(context.Context, *InstallReleaseRequest) (*InstallReleaseResponse, error) {
	return nil, status.Errorf(codes.Unimplemented, "method InstallRelease not implemented")
}
func (UnimplementedApplicationServiceServer) UpgradeReleaseWithChartInfo(context.Context, *InstallReleaseRequest) (*UpgradeReleaseResponse, error) {
	return nil, status.Errorf(codes.Unimplemented, "method UpgradeReleaseWithChartInfo not implemented")
}
func (UnimplementedApplicationServiceServer) IsReleaseInstalled(context.Context, *ReleaseIdentifier) (*BooleanResponse, error) {
	return nil, status.Errorf(codes.Unimplemented, "method IsReleaseInstalled not implemented")
}
func (UnimplementedApplicationServiceServer) RollbackRelease(context.Context, *RollbackReleaseRequest) (*BooleanResponse, error) {
	return nil, status.Errorf(codes.Unimplemented, "method RollbackRelease not implemented")
}
func (UnimplementedApplicationServiceServer) TemplateChart(context.Context, *InstallReleaseRequest) (*TemplateChartResponse, error) {
	return nil, status.Errorf(codes.Unimplemented, "method TemplateChart not implemented")
}
func (UnimplementedApplicationServiceServer) InstallReleaseWithCustomChart(context.Context, *HelmInstallCustomRequest) (*HelmInstallCustomResponse, error) {
	return nil, status.Errorf(codes.Unimplemented, "method InstallReleaseWithCustomChart not implemented")
}
func (UnimplementedApplicationServiceServer) GetNotes(context.Context, *InstallReleaseRequest) (*ChartNotesResponse, error) {
	return nil, status.Errorf(codes.Unimplemented, "method GetNotes not implemented")
}
func (UnimplementedApplicationServiceServer) UpgradeReleaseWithCustomChart(context.Context, *UpgradeReleaseRequest) (*UpgradeReleaseResponse, error) {
	return nil, status.Errorf(codes.Unimplemented, "method UpgradeReleaseWithCustomChart not implemented")
}
func (UnimplementedApplicationServiceServer) ValidateOCIRegistry(context.Context, *RegistryCredential) (*OCIRegistryResponse, error) {
	return nil, status.Errorf(codes.Unimplemented, "method ValidateOCIRegistry not implemented")
}
func (UnimplementedApplicationServiceServer) mustEmbedUnimplementedApplicationServiceServer() {}

// UnsafeApplicationServiceServer may be embedded to opt out of forward compatibility for this service.
// Use of this interface is not recommended, as added methods to ApplicationServiceServer will
// result in compilation errors.
type UnsafeApplicationServiceServer interface {
	mustEmbedUnimplementedApplicationServiceServer()
}

func RegisterApplicationServiceServer(s grpc.ServiceRegistrar, srv ApplicationServiceServer) {
	s.RegisterService(&ApplicationService_ServiceDesc, srv)
}

func _ApplicationService_ListApplications_Handler(srv interface{}, stream grpc.ServerStream) error {
	m := new(AppListRequest)
	if err := stream.RecvMsg(m); err != nil {
		return err
	}
	return srv.(ApplicationServiceServer).ListApplications(m, &applicationServiceListApplicationsServer{stream})
}

type ApplicationService_ListApplicationsServer interface {
	Send(*DeployedAppList) error
	grpc.ServerStream
}

type applicationServiceListApplicationsServer struct {
	grpc.ServerStream
}

func (x *applicationServiceListApplicationsServer) Send(m *DeployedAppList) error {
	return x.ServerStream.SendMsg(m)
}

func _ApplicationService_GetAppDetail_Handler(srv interface{}, ctx context.Context, dec func(interface{}) error, interceptor grpc.UnaryServerInterceptor) (interface{}, error) {
	in := new(AppDetailRequest)
	if err := dec(in); err != nil {
		return nil, err
	}
	if interceptor == nil {
		return srv.(ApplicationServiceServer).GetAppDetail(ctx, in)
	}
	info := &grpc.UnaryServerInfo{
		Server:     srv,
		FullMethod: "/ApplicationService/GetAppDetail",
	}
	handler := func(ctx context.Context, req interface{}) (interface{}, error) {
		return srv.(ApplicationServiceServer).GetAppDetail(ctx, req.(*AppDetailRequest))
	}
	return interceptor(ctx, in, info, handler)
}

func _ApplicationService_GetAppStatus_Handler(srv interface{}, ctx context.Context, dec func(interface{}) error, interceptor grpc.UnaryServerInterceptor) (interface{}, error) {
	in := new(AppDetailRequest)
	if err := dec(in); err != nil {
		return nil, err
	}
	if interceptor == nil {
		return srv.(ApplicationServiceServer).GetAppStatus(ctx, in)
	}
	info := &grpc.UnaryServerInfo{
		Server:     srv,
		FullMethod: "/ApplicationService/GetAppStatus",
	}
	handler := func(ctx context.Context, req interface{}) (interface{}, error) {
		return srv.(ApplicationServiceServer).GetAppStatus(ctx, req.(*AppDetailRequest))
	}
	return interceptor(ctx, in, info, handler)
}

func _ApplicationService_Hibernate_Handler(srv interface{}, ctx context.Context, dec func(interface{}) error, interceptor grpc.UnaryServerInterceptor) (interface{}, error) {
	in := new(HibernateRequest)
	if err := dec(in); err != nil {
		return nil, err
	}
	if interceptor == nil {
		return srv.(ApplicationServiceServer).Hibernate(ctx, in)
	}
	info := &grpc.UnaryServerInfo{
		Server:     srv,
		FullMethod: "/ApplicationService/Hibernate",
	}
	handler := func(ctx context.Context, req interface{}) (interface{}, error) {
		return srv.(ApplicationServiceServer).Hibernate(ctx, req.(*HibernateRequest))
	}
	return interceptor(ctx, in, info, handler)
}

func _ApplicationService_UnHibernate_Handler(srv interface{}, ctx context.Context, dec func(interface{}) error, interceptor grpc.UnaryServerInterceptor) (interface{}, error) {
	in := new(HibernateRequest)
	if err := dec(in); err != nil {
		return nil, err
	}
	if interceptor == nil {
		return srv.(ApplicationServiceServer).UnHibernate(ctx, in)
	}
	info := &grpc.UnaryServerInfo{
		Server:     srv,
		FullMethod: "/ApplicationService/UnHibernate",
	}
	handler := func(ctx context.Context, req interface{}) (interface{}, error) {
		return srv.(ApplicationServiceServer).UnHibernate(ctx, req.(*HibernateRequest))
	}
	return interceptor(ctx, in, info, handler)
}

func _ApplicationService_GetDeploymentHistory_Handler(srv interface{}, ctx context.Context, dec func(interface{}) error, interceptor grpc.UnaryServerInterceptor) (interface{}, error) {
	in := new(AppDetailRequest)
	if err := dec(in); err != nil {
		return nil, err
	}
	if interceptor == nil {
		return srv.(ApplicationServiceServer).GetDeploymentHistory(ctx, in)
	}
	info := &grpc.UnaryServerInfo{
		Server:     srv,
		FullMethod: "/ApplicationService/GetDeploymentHistory",
	}
	handler := func(ctx context.Context, req interface{}) (interface{}, error) {
		return srv.(ApplicationServiceServer).GetDeploymentHistory(ctx, req.(*AppDetailRequest))
	}
	return interceptor(ctx, in, info, handler)
}

func _ApplicationService_GetValuesYaml_Handler(srv interface{}, ctx context.Context, dec func(interface{}) error, interceptor grpc.UnaryServerInterceptor) (interface{}, error) {
	in := new(AppDetailRequest)
	if err := dec(in); err != nil {
		return nil, err
	}
	if interceptor == nil {
		return srv.(ApplicationServiceServer).GetValuesYaml(ctx, in)
	}
	info := &grpc.UnaryServerInfo{
		Server:     srv,
		FullMethod: "/ApplicationService/GetValuesYaml",
	}
	handler := func(ctx context.Context, req interface{}) (interface{}, error) {
		return srv.(ApplicationServiceServer).GetValuesYaml(ctx, req.(*AppDetailRequest))
	}
	return interceptor(ctx, in, info, handler)
}

func _ApplicationService_GetDesiredManifest_Handler(srv interface{}, ctx context.Context, dec func(interface{}) error, interceptor grpc.UnaryServerInterceptor) (interface{}, error) {
	in := new(ObjectRequest)
	if err := dec(in); err != nil {
		return nil, err
	}
	if interceptor == nil {
		return srv.(ApplicationServiceServer).GetDesiredManifest(ctx, in)
	}
	info := &grpc.UnaryServerInfo{
		Server:     srv,
		FullMethod: "/ApplicationService/GetDesiredManifest",
	}
	handler := func(ctx context.Context, req interface{}) (interface{}, error) {
		return srv.(ApplicationServiceServer).GetDesiredManifest(ctx, req.(*ObjectRequest))
	}
	return interceptor(ctx, in, info, handler)
}

func _ApplicationService_UninstallRelease_Handler(srv interface{}, ctx context.Context, dec func(interface{}) error, interceptor grpc.UnaryServerInterceptor) (interface{}, error) {
	in := new(ReleaseIdentifier)
	if err := dec(in); err != nil {
		return nil, err
	}
	if interceptor == nil {
		return srv.(ApplicationServiceServer).UninstallRelease(ctx, in)
	}
	info := &grpc.UnaryServerInfo{
		Server:     srv,
		FullMethod: "/ApplicationService/UninstallRelease",
	}
	handler := func(ctx context.Context, req interface{}) (interface{}, error) {
		return srv.(ApplicationServiceServer).UninstallRelease(ctx, req.(*ReleaseIdentifier))
	}
	return interceptor(ctx, in, info, handler)
}

func _ApplicationService_UpgradeRelease_Handler(srv interface{}, ctx context.Context, dec func(interface{}) error, interceptor grpc.UnaryServerInterceptor) (interface{}, error) {
	in := new(UpgradeReleaseRequest)
	if err := dec(in); err != nil {
		return nil, err
	}
	if interceptor == nil {
		return srv.(ApplicationServiceServer).UpgradeRelease(ctx, in)
	}
	info := &grpc.UnaryServerInfo{
		Server:     srv,
		FullMethod: "/ApplicationService/UpgradeRelease",
	}
	handler := func(ctx context.Context, req interface{}) (interface{}, error) {
		return srv.(ApplicationServiceServer).UpgradeRelease(ctx, req.(*UpgradeReleaseRequest))
	}
	return interceptor(ctx, in, info, handler)
}

func _ApplicationService_GetDeploymentDetail_Handler(srv interface{}, ctx context.Context, dec func(interface{}) error, interceptor grpc.UnaryServerInterceptor) (interface{}, error) {
	in := new(DeploymentDetailRequest)
	if err := dec(in); err != nil {
		return nil, err
	}
	if interceptor == nil {
		return srv.(ApplicationServiceServer).GetDeploymentDetail(ctx, in)
	}
	info := &grpc.UnaryServerInfo{
		Server:     srv,
		FullMethod: "/ApplicationService/GetDeploymentDetail",
	}
	handler := func(ctx context.Context, req interface{}) (interface{}, error) {
		return srv.(ApplicationServiceServer).GetDeploymentDetail(ctx, req.(*DeploymentDetailRequest))
	}
	return interceptor(ctx, in, info, handler)
}

func _ApplicationService_InstallRelease_Handler(srv interface{}, ctx context.Context, dec func(interface{}) error, interceptor grpc.UnaryServerInterceptor) (interface{}, error) {
	in := new(InstallReleaseRequest)
	if err := dec(in); err != nil {
		return nil, err
	}
	if interceptor == nil {
		return srv.(ApplicationServiceServer).InstallRelease(ctx, in)
	}
	info := &grpc.UnaryServerInfo{
		Server:     srv,
		FullMethod: "/ApplicationService/InstallRelease",
	}
	handler := func(ctx context.Context, req interface{}) (interface{}, error) {
		return srv.(ApplicationServiceServer).InstallRelease(ctx, req.(*InstallReleaseRequest))
	}
	return interceptor(ctx, in, info, handler)
}

func _ApplicationService_UpgradeReleaseWithChartInfo_Handler(srv interface{}, ctx context.Context, dec func(interface{}) error, interceptor grpc.UnaryServerInterceptor) (interface{}, error) {
	in := new(InstallReleaseRequest)
	if err := dec(in); err != nil {
		return nil, err
	}
	if interceptor == nil {
		return srv.(ApplicationServiceServer).UpgradeReleaseWithChartInfo(ctx, in)
	}
	info := &grpc.UnaryServerInfo{
		Server:     srv,
		FullMethod: "/ApplicationService/UpgradeReleaseWithChartInfo",
	}
	handler := func(ctx context.Context, req interface{}) (interface{}, error) {
		return srv.(ApplicationServiceServer).UpgradeReleaseWithChartInfo(ctx, req.(*InstallReleaseRequest))
	}
	return interceptor(ctx, in, info, handler)
}

func _ApplicationService_IsReleaseInstalled_Handler(srv interface{}, ctx context.Context, dec func(interface{}) error, interceptor grpc.UnaryServerInterceptor) (interface{}, error) {
	in := new(ReleaseIdentifier)
	if err := dec(in); err != nil {
		return nil, err
	}
	if interceptor == nil {
		return srv.(ApplicationServiceServer).IsReleaseInstalled(ctx, in)
	}
	info := &grpc.UnaryServerInfo{
		Server:     srv,
		FullMethod: "/ApplicationService/IsReleaseInstalled",
	}
	handler := func(ctx context.Context, req interface{}) (interface{}, error) {
		return srv.(ApplicationServiceServer).IsReleaseInstalled(ctx, req.(*ReleaseIdentifier))
	}
	return interceptor(ctx, in, info, handler)
}

func _ApplicationService_RollbackRelease_Handler(srv interface{}, ctx context.Context, dec func(interface{}) error, interceptor grpc.UnaryServerInterceptor) (interface{}, error) {
	in := new(RollbackReleaseRequest)
	if err := dec(in); err != nil {
		return nil, err
	}
	if interceptor == nil {
		return srv.(ApplicationServiceServer).RollbackRelease(ctx, in)
	}
	info := &grpc.UnaryServerInfo{
		Server:     srv,
		FullMethod: "/ApplicationService/RollbackRelease",
	}
	handler := func(ctx context.Context, req interface{}) (interface{}, error) {
		return srv.(ApplicationServiceServer).RollbackRelease(ctx, req.(*RollbackReleaseRequest))
	}
	return interceptor(ctx, in, info, handler)
}

func _ApplicationService_TemplateChart_Handler(srv interface{}, ctx context.Context, dec func(interface{}) error, interceptor grpc.UnaryServerInterceptor) (interface{}, error) {
	in := new(InstallReleaseRequest)
	if err := dec(in); err != nil {
		return nil, err
	}
	if interceptor == nil {
		return srv.(ApplicationServiceServer).TemplateChart(ctx, in)
	}
	info := &grpc.UnaryServerInfo{
		Server:     srv,
		FullMethod: "/ApplicationService/TemplateChart",
	}
	handler := func(ctx context.Context, req interface{}) (interface{}, error) {
		return srv.(ApplicationServiceServer).TemplateChart(ctx, req.(*InstallReleaseRequest))
	}
	return interceptor(ctx, in, info, handler)
}

func _ApplicationService_InstallReleaseWithCustomChart_Handler(srv interface{}, ctx context.Context, dec func(interface{}) error, interceptor grpc.UnaryServerInterceptor) (interface{}, error) {
	in := new(HelmInstallCustomRequest)
	if err := dec(in); err != nil {
		return nil, err
	}
	if interceptor == nil {
		return srv.(ApplicationServiceServer).InstallReleaseWithCustomChart(ctx, in)
	}
	info := &grpc.UnaryServerInfo{
		Server:     srv,
		FullMethod: "/ApplicationService/InstallReleaseWithCustomChart",
	}
	handler := func(ctx context.Context, req interface{}) (interface{}, error) {
		return srv.(ApplicationServiceServer).InstallReleaseWithCustomChart(ctx, req.(*HelmInstallCustomRequest))
	}
	return interceptor(ctx, in, info, handler)
}

func _ApplicationService_GetNotes_Handler(srv interface{}, ctx context.Context, dec func(interface{}) error, interceptor grpc.UnaryServerInterceptor) (interface{}, error) {
	in := new(InstallReleaseRequest)
	if err := dec(in); err != nil {
		return nil, err
	}
	if interceptor == nil {
		return srv.(ApplicationServiceServer).GetNotes(ctx, in)
	}
	info := &grpc.UnaryServerInfo{
		Server:     srv,
		FullMethod: "/ApplicationService/GetNotes",
	}
	handler := func(ctx context.Context, req interface{}) (interface{}, error) {
		return srv.(ApplicationServiceServer).GetNotes(ctx, req.(*InstallReleaseRequest))
	}
	return interceptor(ctx, in, info, handler)
}

func _ApplicationService_UpgradeReleaseWithCustomChart_Handler(srv interface{}, ctx context.Context, dec func(interface{}) error, interceptor grpc.UnaryServerInterceptor) (interface{}, error) {
	in := new(UpgradeReleaseRequest)
	if err := dec(in); err != nil {
		return nil, err
	}
	if interceptor == nil {
		return srv.(ApplicationServiceServer).UpgradeReleaseWithCustomChart(ctx, in)
	}
	info := &grpc.UnaryServerInfo{
		Server:     srv,
		FullMethod: "/ApplicationService/UpgradeReleaseWithCustomChart",
	}
	handler := func(ctx context.Context, req interface{}) (interface{}, error) {
		return srv.(ApplicationServiceServer).UpgradeReleaseWithCustomChart(ctx, req.(*UpgradeReleaseRequest))
	}
	return interceptor(ctx, in, info, handler)
}

func _ApplicationService_ValidateOCIRegistry_Handler(srv interface{}, ctx context.Context, dec func(interface{}) error, interceptor grpc.UnaryServerInterceptor) (interface{}, error) {
	in := new(RegistryCredential)
	if err := dec(in); err != nil {
		return nil, err
	}
	if interceptor == nil {
		return srv.(ApplicationServiceServer).ValidateOCIRegistry(ctx, in)
	}
	info := &grpc.UnaryServerInfo{
		Server:     srv,
		FullMethod: "/ApplicationService/ValidateOCIRegistry",
	}
	handler := func(ctx context.Context, req interface{}) (interface{}, error) {
		return srv.(ApplicationServiceServer).ValidateOCIRegistry(ctx, req.(*RegistryCredential))
	}
	return interceptor(ctx, in, info, handler)
}

// ApplicationService_ServiceDesc is the grpc.ServiceDesc for ApplicationService service.
// It's only intended for direct use with grpc.RegisterService,
// and not to be introspected or modified (even as a copy)
var ApplicationService_ServiceDesc = grpc.ServiceDesc{
	ServiceName: "ApplicationService",
	HandlerType: (*ApplicationServiceServer)(nil),
	Methods: []grpc.MethodDesc{
		{
			MethodName: "GetAppDetail",
			Handler:    _ApplicationService_GetAppDetail_Handler,
		},
		{
			MethodName: "GetAppStatus",
			Handler:    _ApplicationService_GetAppStatus_Handler,
		},
		{
			MethodName: "Hibernate",
			Handler:    _ApplicationService_Hibernate_Handler,
		},
		{
			MethodName: "UnHibernate",
			Handler:    _ApplicationService_UnHibernate_Handler,
		},
		{
			MethodName: "GetDeploymentHistory",
			Handler:    _ApplicationService_GetDeploymentHistory_Handler,
		},
		{
			MethodName: "GetValuesYaml",
			Handler:    _ApplicationService_GetValuesYaml_Handler,
		},
		{
			MethodName: "GetDesiredManifest",
			Handler:    _ApplicationService_GetDesiredManifest_Handler,
		},
		{
			MethodName: "UninstallRelease",
			Handler:    _ApplicationService_UninstallRelease_Handler,
		},
		{
			MethodName: "UpgradeRelease",
			Handler:    _ApplicationService_UpgradeRelease_Handler,
		},
		{
			MethodName: "GetDeploymentDetail",
			Handler:    _ApplicationService_GetDeploymentDetail_Handler,
		},
		{
			MethodName: "InstallRelease",
			Handler:    _ApplicationService_InstallRelease_Handler,
		},
		{
			MethodName: "UpgradeReleaseWithChartInfo",
			Handler:    _ApplicationService_UpgradeReleaseWithChartInfo_Handler,
		},
		{
			MethodName: "IsReleaseInstalled",
			Handler:    _ApplicationService_IsReleaseInstalled_Handler,
		},
		{
			MethodName: "RollbackRelease",
			Handler:    _ApplicationService_RollbackRelease_Handler,
		},
		{
			MethodName: "TemplateChart",
			Handler:    _ApplicationService_TemplateChart_Handler,
		},
		{
			MethodName: "InstallReleaseWithCustomChart",
			Handler:    _ApplicationService_InstallReleaseWithCustomChart_Handler,
		},
		{
			MethodName: "GetNotes",
			Handler:    _ApplicationService_GetNotes_Handler,
		},
		{
			MethodName: "UpgradeReleaseWithCustomChart",
			Handler:    _ApplicationService_UpgradeReleaseWithCustomChart_Handler,
		},
		{
			MethodName: "ValidateOCIRegistry",
			Handler:    _ApplicationService_ValidateOCIRegistry_Handler,
		},
	},
	Streams: []grpc.StreamDesc{
		{
			StreamName:    "ListApplications",
			Handler:       _ApplicationService_ListApplications_Handler,
			ServerStreams: true,
		},
	},
	Metadata: "api/helm-app/applist.proto",
}
