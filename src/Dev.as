// c 2024-03-19
// m 2024-03-19

const uint16 GetMemberOffset(CMwNod@ nod, const string &in memberName) {
    const Reflection::MwClassInfo@ type = Reflection::TypeOf(nod);

    if (type is null)
        throw("Unable to find reflection info for nod");

    const Reflection::MwMemberInfo@ member = type.GetMember(memberName);

    if (member is null)
        throw("Unable to find member \"" + memberName + "\" in \"" + type.Name + "\"");

    return member.Offset;
}