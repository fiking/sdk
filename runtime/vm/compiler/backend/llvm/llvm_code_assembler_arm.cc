void CodeAssembler::CallWithCallReg(const CallSiteInfo* call_site_info,
                                    dart::Register reg) {
  if (LIKELY(!call_site_info->is_tailcall()))
    assembler().blx(reg);
  else
    assembler().bx(reg);
}

void CodeAssembler::GenerateNativeCall(const CallSiteInfo* call_site_info) {
  assembler().add(R2, SP,
                  compiler::Operand(call_site_info->stack_parameter_count() *
                                    compiler::target::kWordSize));
  assembler().LoadWordFromPoolIndex(
      R9, call_site_info->native_entry_pool_offset() - kHeapObjectTag, PP, AL);
  assembler().LoadWordFromPoolIndex(
      CODE_REG, call_site_info->stub_pool_offset() - kHeapObjectTag, PP, AL);
  assembler().ldr(LR, compiler::FieldAddress(
                          CODE_REG, compiler::target::Code::entry_point_offset(
                                        CodeEntryKind::kNormal)));
  assembler().blx(
      LR);  // Use blx instruction so that the return branch prediction works.
}

void CodeAssembler::GeneratePatchableCall(const CallSiteInfo* call_site_info) {
  assembler().LoadWordFromPoolIndex(
      LR, call_site_info->target_stub_pool_offset() - kHeapObjectTag, PP, AL);
  assembler().LoadWordFromPoolIndex(
      R9, call_site_info->ic_pool_offset() - kHeapObjectTag, PP, AL);
  assembler().blx(
      LR);  // Use blx instruction so that the return branch prediction works.
}

void CodeAssembler::PrepareLoadCPAction() {}
void CodeAssembler::EmitCP() {}

struct CodeAssembler::ArchImpl {};
